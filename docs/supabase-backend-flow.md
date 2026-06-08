# Supabase Backend Flow

Combin now uses Supabase Auth, Postgres/RLS, private Storage, and one Edge
Function for the vibe-check pipeline.

## Runtime Flow

1. The app launches and calls `SupabaseConfig.configure()`.
2. `AuthService` restores a Supabase session or creates an anonymous user.
3. `PhotoUploadService` uploads JPEGs to private bucket `outfit-photos` at
   `{uid}/photos/{photoId}.jpg`.
4. `VibeCheckService` invokes `process-vibe-check` with the photo path and device
   metadata.
5. The Edge Function validates the JWT, validates path ownership, claims the daily
   rate-limit slot, downloads the private image, and runs Stage 1/Stage 2 Gemini
   calls server-side.
6. The function streams SSE events:
   - `stage1`: fast one-liner and confidence.
   - `stage2`: tweak, style vector, and garment extraction.
   - `saved`: saved vibe-check id, wardrobe item count, and remaining daily calls.
7. The function inserts `vibe_checks` and fans extracted garments into
   `wardrobe_items`.
8. The wardrobe reads recent `vibe_checks` and private images directly from
   Supabase using the signed-in user session.

## Local Setup

Install Supabase CLI and Deno, then:

```bash
supabase start
supabase db reset
supabase functions serve process-vibe-check --env-file supabase/.env.example
```

Use `GEMINI_MOCK=1` for local streaming tests without live AI calls. For real AI,
set `GEMINI_API_KEY` in the Edge Function environment.
