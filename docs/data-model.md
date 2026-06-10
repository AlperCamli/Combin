# Combin Data Model (schema v2)

The Supabase Postgres model behind the vibe-check loop. Schema v2 folds in the
detailed-analysis ideas from the earlier rate-fit prototype (its
`outfit_analysis`, `outfit_items`, `outfit_item_colors`, `outfit_palette`,
`outfit_metadata` tables and `outfits.thumb_path`) — **without** its scoring
mechanics: Combin never stores or shows user-facing scores, and every row is
protected by RLS (`user_id = auth.uid()`). Migrations live in
`supabase/migrations/`; this file describes the result.

Rather than the prototype's eleven tables, Combin keeps two user-data tables and
inlines the one-to-one satellites (analysis, palette, capture metadata) as
`jsonb` on `vibe_checks` — they are always written and read together by one Edge
Function, so normalizing them bought nothing at MVP scale.

## Table `vibe_checks`

One row per completed backend processing attempt. Written only by the
`process-vibe-check` Edge Function with the caller's JWT.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` | RLS scope, references `auth.users` |
| `photo_path` | `text` | `{uid}/photos/{photoId}.jpg` in private bucket `outfit-photos` |
| `thumb_path` | `text` | Nullable. Client-generated `{photoId}_thumb.jpg` for grid views |
| `stage1_text` | `text` | The hero one-liner |
| `stage1_confidence` | `numeric` | 0–1 |
| `tweak_text` | `text` | Nullable — null means "it already works" |
| `summary` | `text` | The longer read (expanded view). Voice rules apply |
| `style_vector` | `jsonb` | Internal 0–100 axes: formality, trendiness, boldness, colorfulness, cohesion, layering_complexity, accessory_density, silhouette_relaxed_vs_tailored, seasonality_warmth, contrast, monochrome_index, neutral_ratio |
| `style_tags` | `text[]` | e.g. `{minimal, soft-tailoring}` |
| `occasion_fit` | `jsonb` | Internal 0–100 per occasion: casual, office, evening, formal, active |
| `palette` | `jsonb` | Color story, dominant first: `[{ name, hex, percent }]` |
| `photo_quality` | `jsonb` | `{ person_detected, face_visible, lighting, blurriness, confidence, warnings }` — drives edge-case copy |
| `garments` | `jsonb` | Raw Stage 2 garment array (provenance; fan-out lives in `wardrobe_items`) |
| `device` | `jsonb` | `{ os, model }` |
| `stage1_latency_ms` / `stage2_latency_ms` | `int` | |
| `stage1_model` / `stage2_model` | `text` | Model provenance |
| `schema_version` | `int` | `2` for rows written by this analyzer |
| `created_at` | `timestamptz` | |

## Table `wardrobe_items`

Stage 2 garment fan-out — one row per detected garment (the prototype's
`outfit_items` + `outfit_item_colors`, minus `item_score`).

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` | RLS scope |
| `source_vibe_check_id` | `uuid` | References `vibe_checks`, cascade delete |
| `source_photo_path` | `text` | The look photo it was extracted from |
| `category` | `text` | outerwear / top / bottom / footwear / accessory |
| `type` | `text` | e.g. "shirt" |
| `subtype` | `text` | e.g. "oversized oxford" |
| `color` | `text` | Primary color name |
| `colors` | `jsonb` | `[{ name, hex, percent }]` per garment |
| `pattern` | `text` | e.g. "solid", "plaid" |
| `material_guess` | `text` | e.g. "cotton", "wool blend" |
| `fit` | `text` | e.g. "relaxed", "tailored" |
| `confidence` | `numeric` | 0–1 |
| `comment` | `text` | One warm stylist note about the piece |
| `attributes` | `jsonb` | Legacy catch-all; empty for v2 rows |
| `status` | `text` | `active` (future: donated / hidden) |
| `created_at` | `timestamptz` | |

## Table `daily_usage`

Per-user daily counters, written only by the atomic
`claim_daily_vibe_check(limit)` security-definer RPC. Clients can read their own
row, never write it.

## Table `app_config`

Server-readable JSON config: `stage1_model`, `stage2_model`,
`daily_vibe_check_limit`, `gemini_temperature`, `stage1_prompt_template`,
`stage2_prompt_template`. Never contains secrets.

## Storage

Private bucket `outfit-photos` (5 MiB, JPEG-only). Objects live under
`{uid}/photos/` and policies scope every operation by the first path segment
matching `auth.uid()`. The app downloads images directly with the user's session
(no signed-URL endpoint, no service-role key).

## Deliberately not carried over from the prototype

- `reviews.overall_score`, `breakdown` scores, `outfit_items.item_score`,
  `outfit_analysis.total_score` — scores violate a Combin non-negotiable.
- `profiles` (subscription/trial), `user_data_consents`, `social_events`,
  `user_ai_feedback` — out of MVP scope.
- `embedding_jobs`, `outfit_embeddings`, `user_profile_aggregates` — style
  similarity is deferred until after the MVP loop is stable.
- `garment_suggestions` + closet matching — deferred; the prototype's match
  heuristic (`0.7 + 0.3 × color equality`, threshold `0.62`) marked every
  same-category item as matched, so it needs a real design first.
- The `get-outfit-photo-urls` signed-URL function — unnecessary under RLS-scoped
  direct storage downloads, and it required the service-role key.
