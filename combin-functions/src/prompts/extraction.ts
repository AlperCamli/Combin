// Garment-extraction reference.
//
// In the MVP, garment extraction is performed as part of the client's Stage 2
// structured output (see stage2.ts -> "garments"). The `extractGarments` Cloud
// Function does NOT call Gemini — it reads that array from the vibe-check document
// and fans it out into the wardrobe collection.
//
// This prompt fragment is kept only as a reference in case extraction is ever moved
// server-side (e.g. a backfill job, or a Callable extraction path for onboarding's
// first photo per plan Step 2.7 Option B). It is not wired into any live call.
export const EXTRACTION_PROMPT = `
Identify the distinct garments worn in this photo. For each garment return:
- "category": one of outerwear, top, bottom, footwear, accessory
- "type": a short plain-language type, e.g. "trench coat", "loafers"
- "color": plain language, e.g. "camel", "charcoal"
- "confidence": 0 to 1

Do not crop or describe the person. Return an empty array if no clear garments are visible. Output ONLY JSON matching the provided schema.
`.trim();
