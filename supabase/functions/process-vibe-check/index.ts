import { createClient } from "https://esm.sh/@supabase/supabase-js@2.108.0";
import { sendSSE } from "./sse.ts";

const PHOTO_BUCKET = "outfit-photos";
const MAX_PHOTO_BYTES = 5 * 1024 * 1024;

const DEFAULTS = {
  stage1Model: "gemini-3.1-flash-lite",
  stage2Model: "gemini-3.5-flash",
  dailyLimit: 1000,
  stage1Prompt:
    `You are Combin - a fashion-literate friend who just got a photo of what someone is wearing and texts back fast. Return ONLY JSON with "vibe_check" and "confidence".`,
  stage2Prompt:
    `You are Combin, reading the same outfit more closely. Return ONLY JSON with "tweak", "style_vector", and "garments".`,
};

type DeviceInfo = { os?: string; model?: string };

type Stage1Result = {
  vibe_check: string;
  confidence: number;
  latencyMs: number;
};

type StyleVector = {
  vibe: number;
  formality: number;
  colorfulness: number;
  cohesion: number;
  statement_strength: number;
};

type Garment = {
  category?: string | null;
  type?: string | null;
  color?: string | null;
  confidence?: number | null;
  attributes?: Record<string, unknown> | null;
};

type Stage2Result = {
  tweak: string | null;
  style_vector: StyleVector;
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

  let body: { photoPath?: string; device?: DeviceInfo };
  try {
    body = await req.json();
  } catch {
    return json({ message: "Invalid JSON body" }, 400);
  }

  const photoPath = body.photoPath;
  if (!photoPath || !ownsPhotoPath(user.id, photoPath)) {
    return json({ message: "Invalid photoPath" }, 400);
  }

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
  device: DeviceInfo;
  imageBytes: Uint8Array;
  config: Record<string, unknown>;
  remaining: number | null;
}) {
  const stage1Promise = runStage1(args.imageBytes, args.config);
  const stage2Promise = runStage2(args.imageBytes, args.config);

  const stage1 = await stage1Promise;
  sendSSE(args.controller, "stage1", {
    text: stage1.vibe_check,
    confidence: stage1.confidence,
    latencyMs: stage1.latencyMs,
  });

  const stage2 = await stage2Promise;
  sendSSE(args.controller, "stage2", {
    tweakText: stage2.tweak,
    styleVector: stage2.style_vector,
    garments: stage2.garments,
    latencyMs: stage2.latencyMs,
  });

  const { data: savedRows, error: saveError } = await args.supabase
    .from("vibe_checks")
    .insert({
      user_id: args.userId,
      photo_path: args.photoPath,
      stage1_text: stage1.vibe_check,
      stage1_confidence: stage1.confidence,
      tweak_text: stage2.tweak,
      style_vector: stage2.style_vector,
      garments: stage2.garments,
      device: args.device,
      stage1_latency_ms: stage1.latencyMs,
      stage2_latency_ms: stage2.latencyMs,
    })
    .select("id")
    .single();

  if (saveError) throw saveError;
  const vibeCheckId = savedRows.id as string;

  const wardrobeRows = stage2.garments.map((garment) => ({
    user_id: args.userId,
    source_vibe_check_id: vibeCheckId,
    source_photo_path: args.photoPath,
    category: garment.category ?? null,
    type: garment.type ?? null,
    color: garment.color ?? null,
    confidence: garment.confidence ?? null,
    attributes: garment.attributes ?? {},
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

async function runStage1(imageBytes: Uint8Array, config: Record<string, unknown>): Promise<Stage1Result> {
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
    model: stringConfig(config.stage1_model, DEFAULTS.stage1Model),
    prompt: stringConfig(config.stage1_prompt_template, DEFAULTS.stage1Prompt),
    imageBytes,
    schema: stage1Schema,
  });
  return {
    vibe_check: String(json.vibe_check ?? ""),
    confidence: Number(json.confidence ?? 0),
    latencyMs: Math.round(performance.now() - start),
  };
}

async function runStage2(imageBytes: Uint8Array, config: Record<string, unknown>): Promise<Stage2Result> {
  if (Deno.env.get("GEMINI_MOCK") === "1") {
    await sleep(350);
    return {
      tweak: "Try a softer belt here - it would pull the palette together without changing the mood.",
      style_vector: {
        vibe: 72,
        formality: 58,
        colorfulness: 36,
        cohesion: 84,
        statement_strength: 42,
      },
      garments: [
        { category: "top", type: "shirt", color: "cream", confidence: 0.82 },
      ],
      latencyMs: 350,
    };
  }

  const start = performance.now();
  const json = await callGemini({
    model: stringConfig(config.stage2_model, DEFAULTS.stage2Model),
    prompt: stringConfig(config.stage2_prompt_template, DEFAULTS.stage2Prompt),
    imageBytes,
    schema: stage2Schema,
  });
  return {
    tweak: typeof json.tweak === "string" ? json.tweak : null,
    style_vector: json.style_vector as StyleVector,
    garments: Array.isArray(json.garments) ? json.garments as Garment[] : [],
    latencyMs: Math.round(performance.now() - start),
  };
}

async function callGemini(args: {
  model: string;
  prompt: string;
  imageBytes: Uint8Array;
  schema: Record<string, unknown>;
}): Promise<Record<string, unknown>> {
  const apiKey = requiredEnv("GEMINI_API_KEY");
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
            { text: args.prompt },
            {
              inline_data: {
                mime_type: "image/jpeg",
                data: base64(args.imageBytes),
              },
            },
          ],
        }],
        generationConfig: {
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
  return JSON.parse(text);
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

const stage2Schema = {
  type: "object",
  properties: {
    tweak: { type: ["string", "null"] },
    style_vector: {
      type: "object",
      properties: {
        vibe: { type: "integer" },
        formality: { type: "integer" },
        colorfulness: { type: "integer" },
        cohesion: { type: "integer" },
        statement_strength: { type: "integer" },
      },
      required: ["vibe", "formality", "colorfulness", "cohesion", "statement_strength"],
    },
    garments: {
      type: "array",
      items: {
        type: "object",
        properties: {
          category: { type: "string" },
          type: { type: "string" },
          color: { type: "string" },
          confidence: { type: "number" },
          attributes: { type: "object" },
        },
      },
    },
  },
  required: ["style_vector", "garments"],
};
