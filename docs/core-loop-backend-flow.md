# Core Loop — Supabase Backend Flow

The Daily Vibe Check now runs on Supabase plus a backend-owned Gemini pipeline.

## Cold Start

1. `CombinApp` calls `SupabaseConfig.configure()`.
2. If `SupabaseConfig.plist` is missing or still contains placeholders, the app runs
   in UI-only demo mode.
3. With real config, `AuthService` restores the Supabase session or creates an
   anonymous user. That uid scopes all Postgres rows and Storage objects through RLS.

## Capture And Upload

4. The camera and picker stay local until the user chooses a photo.
5. `VibeCheckViewModel` compresses the image to JPEG.
6. `PhotoUploadService` uploads it to private Supabase Storage:
   `{uid}/photos/{photoId}.jpg` in bucket `outfit-photos`.
7. Failed uploads are kept in the existing local pending-upload queue and retried
   after the next authenticated launch.

## Backend Processing

8. `VibeCheckService` calls the authenticated Edge Function
   `process-vibe-check` with `{ photoPath, device }`.
9. The function validates the JWT, verifies the photo path belongs to the caller,
   claims a daily rate-limit slot through `claim_daily_vibe_check(limit)`, downloads
   the private image server-side, and sends image bytes to Gemini.
10. Stage 1 and Stage 2 run in parallel on the backend. Gemini API keys, model names,
    prompt defaults, and persistence stay off-device.

## Streamed Result

The Edge Function returns Server-Sent Events:

- `stage1`: fast one-liner, confidence, latency.
- `stage2`: optional tweak, style vector, garments, latency.
- `saved`: saved `vibe_checks.id`, wardrobe item count, remaining daily calls.

The app reveals Stage 1 as soon as it arrives, fades in Stage 2 when available, and
uses the saved id for onboarding's wardrobe extraction poll.

## Persistence

The Edge Function inserts:

- One row in `vibe_checks`.
- Zero or more rows in `wardrobe_items`, fanned out from Stage 2 garments.
- One counter update in `daily_usage`.

The wardrobe reads `vibe_checks` and `wardrobe_items` directly from Supabase with
RLS enforcing `user_id = auth.uid()`.
