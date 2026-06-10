import { createClient } from "https://esm.sh/@supabase/supabase-js@2.108.0";
import { sendSSE } from "./sse.ts";

const PHOTO_BUCKET = "outfit-photos";
const MAX_PHOTO_BYTES = 5 * 1024 * 1024;
const SCHEMA_VERSION = 2;

const DEFAULTS = {
  stage1Model: "gemini-3.1-flash-lite",
  stage2Model: "gemini-3.5-flash",
  dailyLimit: 1000,
  temperature: 0.25,
  stage1Prompt:
    `You are Combin - a fashion-literate friend who just got a photo of what someone is wearing and texts back fast. Return ONLY JSON with "vibe_check" and "confidence".`,
  stage2Prompt:
    `You are Combin, reading the same outfit more closely. Return ONLY JSON matching the schema: "tweak", "summary", "style_vector", "style_tags", "occasion_fit", "palette", "photo_quality", and "garments".`,
};

type DeviceInfo = { os?: string; model?: string };

type Stage1Result = {
  vibe_check: string;
  confidence: number;
  latencyMs: number;
};

// Internal 0-100 axes (schema v2) — never surfaced to the user as scores.
type StyleVector = {
  formality: number;
  trendiness: number;
  boldness: number;
  colorfulness: number;
  cohesion: number;
  layering_complexity: number;
  accessory_density: number;
  silhouette_relaxed_vs_tailored: number;
  seasonality_warmth: number;
  contrast: number;
  monochrome_index: number;
  neutral_ratio: number;
};

type ColorReading = {
  name?: string | null;
  hex?: string | null;
  percent?: number | null;
};

type Garment = {
  slot?: string | null;
  category?: string | null;
  type?: string | null;
  subtype?: string | null;
  color?: string | null;
  colors?: ColorReading[] | null;
  pattern?: string | null;
  material_guess?: string | null;
  fit?: string | null;
  confidence?: number | null;
  comment?: string | null;
};

type PhotoQuality = {
  person_detected?: boolean;
  face_visible?: boolean;
  lighting?: string;
  blurriness?: number;
  confidence?: number;
  warnings?: string[];
};

type Stage2Result = {
  tweak: string | null;
  summary: string | null;
  style_vector: StyleVector;
  style_tags: string[];
  occasion_fit: Record<string, number>;
  palette: ColorReading[];
  photo_quality: PhotoQuality;
  garments: Garment[];
  latencyMs: number;
};

type UntypedSupabaseClient = ReturnType<typeof createClient<any, any, any>>;

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ message: "Method not allowed" }, 405);
  }

  const supabaseUrl = requiredEnv("SUPABASE_URL");
  const anonKey = requiredEnv("SUPABASE_ANON_KEY");
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ message: "Missing Authorization header" }, 401);
  }

  const supabase = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  }) as UntypedSupabaseClient;

  const { data: userData, error: userError } = await supabase.auth.getUser();
  const user = userData.user;
  if (userError || !user) {
    return json({ message: "Sign-in required" }, 401);
  }

  let body: { photoPath?: string; thumbPath?: string; device?: DeviceInfo };
  try {
    body = await req.json();
  } catch {
    return json({ message: "Invalid JSON body" }, 400);
  }

  const photoPath = body.photoPath;
  if (!photoPath || !ownsPhotoPath(user.id, photoPath)) {
    return json({ message: "Invalid photoPath" }, 400);
  }

  // Optional client-generated thumbnail for grid views; same ownership rules.
  const thumbPath = body.thumbPath && ownsPhotoPath(user.id, body.thumbPath)
    ? body.thumbPath
    : null;

  const config = await loadConfig(supabase);
  const limit = numberConfig(config.daily_vibe_check_limit, DEFAULTS.dailyLimit);
  const { data: claimRows, error: claimError } = await supabase.rpc("claim_daily_vibe_check", {
    limit_count: limit,
  });
  if (claimError) {
    console.error("claim_daily_vibe_check failed", claimError);
    return json({ message: "Rate limit check failed" }, 500);
  }

  const claim = Array.isArray(claimRows) ? claimRows[0] : claimRows;
  if (!claim?.allowed) {
    return json(
      { allowed: false, reason: "daily_limit", limit, upgradeAvailable: true },
      429,
    );
  }

  const { data: photo, error: downloadError } = await supabase.storage
    .from(PHOTO_BUCKET)
    .download(photoPath);
  if (downloadError || !photo) {
    console.error("photo download failed", downloadError);
    return json({ message: "Photo not found" }, 404);
  }

  const imageBytes = new Uint8Array(await photo.arrayBuffer());
  if (imageBytes.byteLength > MAX_PHOTO_BYTES) {
    return json({ message: "Photo too large" }, 413);
  }

  const stream = new ReadableStream<Uint8Array>({
    start(controller) {
      runPipeline({
        controller,
        supabase,
        userId: user.id,
        photoPath,
        thumbPath,
        device: body.device ?? {},
        imageBytes,
        config,
        remaining: claim.remaining ?? null,
      }).catch((error) => {
        console.error("process-vibe-check failed", error);
        sendSSE(controller, "error", { message: "Vibe-check failed" });
      }).finally(() => controller.close());
    },
  });

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    },
  });
});

async function runPipeline(args: {
  controller: ReadableStreamDefaultController<Uint8Array>;
  supabase: UntypedSupabaseClient;
  userId: string;
  photoPath: string;
  thumbPath: string | null;
  device: DeviceInfo;
  imageBytes: Uint8Array;
  config: Record<string, unknown>;
  remaining: number | null;
}) {
  const stage1Model = stringConfig(args.config.stage1_model, DEFAULTS.stage1Model);
  const stage2Model = stringConfig(args.config.stage2_model, DEFAULTS.stage2Model);
  const stage1Promise = runStage1(args.imageBytes, args.config, stage1Model);
  const stage2Promise = runStage2(args.imageBytes, args.config, stage2Model);

  const stage1 = await stage1Promise;
  sendSSE(args.controller, "stage1", {
    text: stage1.vibe_check,
    confidence: stage1.confidence,
    latencyMs: stage1.latencyMs,
  });

  const stage2 = await stage2Promise;
  sendSSE(args.controller, "stage2", {
    tweakText: stage2.tweak,
    summary: stage2.summary,
    styleVector: stage2.style_vector,
    styleTags: stage2.style_tags,
    palette: stage2.palette,
    photoQuality: stage2.photo_quality,
    garments: stage2.garments,
    latencyMs: stage2.latencyMs,
  });

  const { data: savedRows, error: saveError } = await args.supabase
    .from("vibe_checks")
    .insert({
      user_id: args.userId,
      photo_path: args.photoPath,
      thumb_path: args.thumbPath,
      stage1_text: stage1.vibe_check,
      stage1_confidence: stage1.confidence,
      tweak_text: stage2.tweak,
      summary: stage2.summary,
      style_vector: stage2.style_vector,
      style_tags: stage2.style_tags,
      occasion_fit: stage2.occasion_fit,
      palette: stage2.palette,
      photo_quality: stage2.photo_quality,
      garments: stage2.garments,
      device: args.device,
      stage1_latency_ms: stage1.latencyMs,
      stage2_latency_ms: stage2.latencyMs,
      stage1_model: stage1Model,
      stage2_model: stage2Model,
      schema_version: SCHEMA_VERSION,
    })
    .select("id")
    .single();

  if (saveError) throw saveError;
  const vibeCheckId = savedRows.id as string;

  const wardrobeRows = stage2.garments.map((garment) => ({
    user_id: args.userId,
    source_vibe_check_id: vibeCheckId,
    source_photo_path: args.photoPath,
    category: garment.category ?? garment.slot ?? null,
    type: garment.type ?? null,
    subtype: garment.subtype ?? null,
    color: garment.color ?? garment.colors?.[0]?.name ?? null,
    colors: garment.colors ?? [],
    pattern: garment.pattern ?? null,
    material_guess: garment.material_guess ?? null,
    fit: garment.fit ?? null,
    confidence: garment.confidence ?? null,
    comment: garment.comment ?? null,
    attributes: {},
    status: "active",
  }));

  if (wardrobeRows.length > 0) {
    const { error } = await args.supabase.from("wardrobe_items").insert(wardrobeRows);
    if (error) throw error;
  }

  sendSSE(args.controller, "saved", {
    vibeCheckId,
    garmentsWritten: wardrobeRows.length,
    remaining: args.remaining,
  });
}

async function runStage1(
  imageBytes: Uint8Array,
  config: Record<string, unknown>,
  model: string,
): Promise<Stage1Result> {
  if (Deno.env.get("GEMINI_MOCK") === "1") {
    await sleep(150);
    return {
      vibe_check: "Three textures, one mood - the layers are doing quiet, useful work.",
      confidence: 0.86,
      latencyMs: 150,
    };
  }

  const start = performance.now();
  const json = await callGemini({
    model,
    prompt: stringConfig(config.stage1_prompt_template, DEFAULTS.stage1Prompt),
    imageBytes,
    schema: stage1Schema,
    temperature: temperatureConfig(config),
  });
  return {
    vibe_check: String(json.vibe_check ?? ""),
    confidence: Number(json.confidence ?? 0),
    latencyMs: Math.round(performance.now() - start),
  };
}

async function runStage2(
  imageBytes: Uint8Array,
  config: Record<string, unknown>,
  model: string,
): Promise<Stage2Result> {
  if (Deno.env.get("GEMINI_MOCK") === "1") {
    await sleep(350);
    return {
      tweak: "Try a softer belt here - it would pull the palette together without changing the mood.",
      summary:
        "The cream shirt is carrying this: it warms the whole frame and lets the darker layers read as intentional instead of heavy. The proportions sit easy, and the palette stays in one conversation.",
      style_vector: {
        formality: 58,
        trendiness: 47,
        boldness: 35,
        colorfulness: 36,
        cohesion: 84,
        layering_complexity: 52,
        accessory_density: 20,
        silhouette_relaxed_vs_tailored: 44,
        seasonality_warmth: 60,
        contrast: 41,
        monochrome_index: 55,
        neutral_ratio: 78,
      },
      style_tags: ["minimal", "soft-tailoring"],
      occasion_fit: { casual: 86, office: 62, evening: 48, formal: 22, active: 10 },
      palette: [
        { name: "cream", hex: "#EFE6D8", percent: 45 },
        { name: "olive", hex: "#6B6B4D", percent: 30 },
        { name: "charcoal", hex: "#3A3A3A", percent: 25 },
      ],
      photo_quality: {
        person_detected: true,
        face_visible: false,
        lighting: "good",
        blurriness: 0.1,
        confidence: 0.88,
        warnings: [],
      },
      garments: [
        {
          slot: "top",
          category: "top",
          type: "shirt",
          subtype: "oversized oxford",
          color: "cream",
          colors: [{ name: "cream", hex: "#EFE6D8", percent: 90 }],
          pattern: "solid",
          material_guess: "cotton",
          fit: "relaxed",
          confidence: 0.82,
          comment: "The drape is doing the anchoring here.",
        },
      ],
      latencyMs: 350,
    };
  }

  const start = performance.now();
  const json = await callGemini({
    model,
    prompt: stringConfig(config.stage2_prompt_template, DEFAULTS.stage2Prompt),
    imageBytes,
    schema: stage2Schema,
    temperature: temperatureConfig(config),
  });
  return {
    tweak: typeof json.tweak === "string" ? json.tweak : null,
    summary: typeof json.summary === "string" ? json.summary : null,
    style_vector: json.style_vector as StyleVector,
    style_tags: stringArray(json.style_tags),
    occasion_fit: (json.occasion_fit ?? {}) as Record<string, number>,
    palette: Array.isArray(json.palette) ? json.palette as ColorReading[] : [],
    photo_quality: (json.photo_quality ?? {}) as PhotoQuality,
    garments: Array.isArray(json.garments) ? json.garments as Garment[] : [],
    latencyMs: Math.round(performance.now() - start),
  };
}

async function callGemini(args: {
  model: string;
  prompt: string;
  imageBytes: Uint8Array;
  schema: Record<string, unknown>;
  temperature: number;
}): Promise<Record<string, unknown>> {
  try {
    return await callGeminiOnce(args, false);
  } catch (error) {
    // One repair pass: structured output occasionally still arrives malformed.
    console.warn(`Gemini ${args.model} first attempt failed; retrying`, error);
    return await callGeminiOnce(args, true);
  }
}

async function callGeminiOnce(
  args: {
    model: string;
    prompt: string;
    imageBytes: Uint8Array;
    schema: Record<string, unknown>;
    temperature: number;
  },
  repair: boolean,
): Promise<Record<string, unknown>> {
  const apiKey = requiredEnv("GEMINI_API_KEY");
  const prompt = repair
    ? `${args.prompt}\n\nThe previous response was not valid JSON for the schema. Return ONLY valid JSON this time.`
    : args.prompt;
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${args.model}:generateContent`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body: JSON.stringify({
        contents: [{
          parts: [
            { text: prompt },
            {
              inline_data: {
                mime_type: "image/jpeg",
                data: base64(args.imageBytes),
              },
            },
          ],
        }],
        generationConfig: {
          temperature: args.temperature,
          responseMimeType: "application/json",
          responseJsonSchema: args.schema,
        },
      }),
    },
  );

  if (!response.ok) {
    throw new Error(`Gemini failed: ${response.status} ${await response.text()}`);
  }
  const payload = await response.json();
  const text = payload.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) throw new Error("Gemini returned no text");
  const parsed = extractJsonObject(text);
  if (!parsed) throw new Error("Gemini returned unparseable JSON");
  return parsed;
}

/// Parse model output as JSON, tolerating markdown fences / leading prose.
function extractJsonObject(text: string): Record<string, unknown> | null {
  const trimmed = text.trim();
  try {
    return JSON.parse(trimmed);
  } catch {
    const first = trimmed.indexOf("{");
    const last = trimmed.lastIndexOf("}");
    if (first === -1 || last <= first) return null;
    try {
      return JSON.parse(trimmed.slice(first, last + 1));
    } catch {
      return null;
    }
  }
}

async function loadConfig(supabase: UntypedSupabaseClient) {
  const { data, error } = await supabase.from("app_config").select("key,value");
  if (error) {
    console.warn("app_config read failed; using defaults", error);
    return {};
  }
  return Object.fromEntries((data ?? []).map((row) => [row.key, row.value]));
}

function ownsPhotoPath(userId: string, photoPath: string) {
  return photoPath.startsWith(`${userId}/photos/`) && photoPath.endsWith(".jpg");
}

function stringConfig(value: unknown, fallback: string): string {
  return typeof value === "string" && value.length > 0 ? value : fallback;
}

function numberConfig(value: unknown, fallback: number): number {
  return typeof value === "number" && value > 0 ? value : fallback;
}

function temperatureConfig(config: Record<string, unknown>): number {
  const value = config.gemini_temperature;
  return typeof value === "number" && value >= 0 && value <= 2 ? value : DEFAULTS.temperature;
}

function stringArray(value: unknown): string[] {
  return Array.isArray(value) ? value.filter((v): v is string => typeof v === "string") : [];
}

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing env var ${name}`);
  return value;
}

function json(payload: unknown, status: number) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function base64(bytes: Uint8Array): string {
  let binary = "";
  const chunkSize = 0x8000;
  for (let i = 0; i < bytes.length; i += chunkSize) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunkSize));
  }
  return btoa(binary);
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

const stage1Schema = {
  type: "object",
  properties: {
    vibe_check: { type: "string" },
    confidence: { type: "number" },
  },
  required: ["vibe_check", "confidence"],
};

const colorSchema = {
  type: "object",
  properties: {
    name: { type: "string" },
    hex: { type: "string" },
    percent: { type: "number" },
  },
  required: ["name"],
};

const stage2Schema = {
  type: "object",
  properties: {
    tweak: { type: ["string", "null"] },
    summary: { type: "string" },
    style_vector: {
      type: "object",
      properties: {
        formality: { type: "integer" },
        trendiness: { type: "integer" },
        boldness: { type: "integer" },
        colorfulness: { type: "integer" },
        cohesion: { type: "integer" },
        layering_complexity: { type: "integer" },
        accessory_density: { type: "integer" },
        silhouette_relaxed_vs_tailored: { type: "integer" },
        seasonality_warmth: { type: "integer" },
        contrast: { type: "integer" },
        monochrome_index: { type: "integer" },
        neutral_ratio: { type: "integer" },
      },
      required: [
        "formality",
        "trendiness",
        "boldness",
        "colorfulness",
        "cohesion",
        "layering_complexity",
        "accessory_density",
        "silhouette_relaxed_vs_tailored",
        "seasonality_warmth",
        "contrast",
        "monochrome_index",
        "neutral_ratio",
      ],
    },
    style_tags: { type: "array", items: { type: "string" } },
    occasion_fit: {
      type: "object",
      properties: {
        casual: { type: "integer" },
        office: { type: "integer" },
        evening: { type: "integer" },
        formal: { type: "integer" },
        active: { type: "integer" },
      },
      required: ["casual", "office", "evening", "formal", "active"],
    },
    palette: { type: "array", items: colorSchema },
    photo_quality: {
      type: "object",
      properties: {
        person_detected: { type: "boolean" },
        face_visible: { type: "boolean" },
        lighting: { type: "string", enum: ["good", "dim", "harsh", "mixed"] },
        blurriness: { type: "number" },
        confidence: { type: "number" },
        warnings: { type: "array", items: { type: "string" } },
      },
      required: ["person_detected", "lighting", "confidence"],
    },
    garments: {
      type: "array",
      items: {
        type: "object",
        properties: {
          slot: { type: "string" },
          category: {
            type: "string",
            enum: ["outerwear", "top", "bottom", "footwear", "accessory"],
          },
          type: { type: "string" },
          subtype: { type: "string" },
          color: { type: "string" },
          colors: { type: "array", items: colorSchema },
          pattern: { type: "string" },
          material_guess: { type: "string" },
          fit: { type: "string" },
          confidence: { type: "number" },
          comment: { type: "string" },
        },
        required: ["category", "type", "color", "confidence"],
      },
    },
  },
  required: [
    "summary",
    "style_vector",
    "style_tags",
    "occasion_fit",
    "palette",
    "photo_quality",
    "garments",
  ],
};
