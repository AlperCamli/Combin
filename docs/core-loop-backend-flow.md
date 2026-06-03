# Core Loop — What the Backend Does, Step by Step

The full "analyze my outfit" journey for the **Daily Vibe Check**, mechanism by
mechanism — what fires when, and which Firebase service handles it. No code, just the
flow.

> Implementation lives in `Combin/Services/`, `Combin/Features/`, and
> `combin-functions/`. See [combin-mvp-implementation-plan.md](combin-mvp-implementation-plan.md)
> for the plan this realizes.

---

## Before any button — cold start

1. **App launches → `FirebaseConfig.configure()`.** It installs the App Check
   provider *before* Firebase starts. From this point, **every** call to Storage,
   Firestore, Vertex AI, and Functions carries a cryptographic App Check token
   proving it came from your real app. Because those services are set to *enforce*,
   anything without a valid token (a script, a stolen API key) is rejected.

2. **Anonymous sign-in.** `AuthService` checks for an existing account. First launch
   → Firebase Auth mints an **anonymous `uid`** that persists across launches.
   Everything the user creates lives under `users/{uid}/…`, and Security Rules let
   *only that uid* touch it.

3. **Remote Config fetch.** Pulls the live model names, prompt templates, and the
   daily rate limit.

## Camera screen

4. `CameraController` runs a live `AVCaptureSession`. **Purely local — no backend
   yet.** (The gallery picker is just an alternative local image source.)

## User taps the shutter ("analyze my outfit")

The captured `UIImage` goes to `VibeCheckViewModel`, which runs the pipeline:

5. **Compress (on-device).** Downscale to ≤2048px long edge, JPEG ~0.75, usually
   <400KB. Smaller = faster upload = faster answer.

6. **Rate-limit check (Cloud Function `checkRateLimit`).** Before spending money on
   Gemini, the app calls this function. It reads `users/{uid}/usage/daily` and the
   `daily_vibe_check_limit` from Remote Config (currently 1000 ≈ unlimited). Under
   the limit → it increments the counter and returns `allowed: true`. Over → returns
   a structured rejection and the app shows the friendly "you've had a lot today"
   copy and stops. (In dev, if the function isn't deployed, the app just proceeds.)

7. **Upload to Cloud Storage (`PhotoUploadService`).** The JPEG goes to
   `users/{uid}/photos/{photoId}.jpg`. Storage Rules verify: the path's uid matches
   the caller, it's an image, <5MB, valid App Check token. On success the app gets
   back a **`gs://` URI** — a *pointer* to the file, not the bytes. (Upload
   fails/offline → photo is queued locally, retried next launch.)

8. **Two Gemini calls fire IN PARALLEL (Vertex AI).** The instant the upload lands:
   - **Stage 1 (fast one-liner):** the app sends Vertex AI the prompt + the `gs://`
     URI. **Vertex reads the photo straight from Cloud Storage** — the bytes never
     route through any server of ours and aren't re-sent from the phone. The answer
     is forced into a strict JSON schema `{vibe_check, confidence}` and **streamed**
     so it arrives fast (~1.5s). The app reveals it word-by-word.
   - **Stage 2 (deeper read):** at the same time, a stronger model returns JSON with
     the optional `tweak`, the 5-axis `style_vector` (internal scoring, never
     shown), and the `garments` list. Lands a bit later (~3.5s); the tweak card
     fades in.
   - The point of parallel-not-sequential: the slower Stage 2 never delays the
     one-liner.

9. **Save to Firestore (Step 1.8).** The app writes one document at
   `users/{uid}/vibeChecks/{id}` — gs:// path, one-liner, tweak, style vector,
   garments, latencies, device, timestamp. Offline persistence means it commits
   **instantly on-device** and syncs in the background. Rules re-check uid + App
   Check.

## Meanwhile, automatically — the wardrobe fills in

10. **`extractGarments` Cloud Function.** The upload in step 7 *also* fired a Storage
    trigger. This function wakes up, identifies the user/photo, finds the matching
    vibe-check document (a short bounded retry, because the document is written
    ~3.5s after the photo lands), and copies each garment into its own
    `users/{uid}/wardrobe/{itemId}` — each pointing back at the same source photo
    (no cropping). It runs with admin privileges (bypasses rules, as intended for
    trusted server code). This is why wardrobe items appear a few seconds after a
    vibe-check.

## Result screen

11. Shows the captured photo, the revealed one-liner, and the tweak card if Stage 2
    returned one. "Go to the wardrobe" lands on the grid where the freshly extracted
    items now live.

---

## The security envelope around all of it

- **App Check** on every call (Storage, Firestore, Vertex AI, Functions).
- **Anonymous-uid scoping** in every Security Rule — a user can only ever read/write
  their own `users/{uid}/…` tree.
- **The photo only ever exists as a `gs://` pointer** that Vertex AI reads
  transiently; the bytes are never persisted anywhere except Cloud Storage.

## Two flagged deviations from the plan (kept on purpose)

- **Storage rules split `read` from `write`.** `request.resource` is null on reads,
  so the plan's combined rule (with size/content-type checks) would have denied
  legitimate photo reads. Reads now check ownership only; writes keep the size +
  image-type checks.
- **`extractGarments` uses a bounded retry.** The photo upload (the trigger) finishes
  *before* the vibe-check document with the garments is written, so the function
  retries until the document appears. Cleaner alternative for later: trigger on the
  Firestore `vibeChecks/{id}` document creation instead of on the photo upload.
