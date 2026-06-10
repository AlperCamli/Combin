-- Detailed outfit analysis (schema v2).
-- Folds in the useful parts of the rate-fit prototype's data model
-- (outfit_analysis, outfit_items, outfit_item_colors, outfit_palette,
-- outfit_metadata, outfits.thumb_path) without its scoring mechanics:
-- Combin never stores or shows scores as user-facing judgements, and all
-- analysis stays on the user's own RLS-protected rows.

alter table public.vibe_checks
  add column if not exists thumb_path text,
  add column if not exists summary text,
  add column if not exists style_tags text[] not null default '{}',
  add column if not exists occasion_fit jsonb,
  add column if not exists palette jsonb not null default '[]'::jsonb,
  add column if not exists photo_quality jsonb,
  add column if not exists stage1_model text,
  add column if not exists stage2_model text,
  add column if not exists schema_version int not null default 2;

alter table public.wardrobe_items
  add column if not exists subtype text,
  add column if not exists pattern text,
  add column if not exists material_guess text,
  add column if not exists fit text,
  add column if not exists colors jsonb not null default '[]'::jsonb,
  add column if not exists comment text;

comment on column public.vibe_checks.thumb_path is
  'Optional client-generated thumbnail under {uid}/photos/, used by grid views.';
comment on column public.vibe_checks.summary is
  'Stage 2 longer read shown in the expanded view. Voice rules apply: no scores, no body language.';
comment on column public.vibe_checks.style_tags is
  'Internal style descriptors (e.g. minimal, prep, street). Never shown as scores.';
comment on column public.vibe_checks.occasion_fit is
  'Internal 0-100 fit per occasion key (casual/office/evening/formal/active). Never user-facing.';
comment on column public.vibe_checks.palette is
  'Outfit color story: array of { name, hex, percent }, ordered most to least dominant.';
comment on column public.vibe_checks.photo_quality is
  'Capture diagnostics from Stage 2: { person_detected, face_visible, lighting, blurriness, confidence, warnings }.';
comment on column public.vibe_checks.style_vector is
  'Internal 0-100 axes (schema v2): formality, trendiness, boldness, colorfulness, cohesion, layering_complexity, accessory_density, silhouette_relaxed_vs_tailored, seasonality_warmth, contrast, monochrome_index, neutral_ratio.';
comment on column public.wardrobe_items.colors is
  'Per-garment colors: array of { name, hex, percent }.';
comment on column public.wardrobe_items.comment is
  'One warm, specific stylist note about the piece. Voice rules apply.';
