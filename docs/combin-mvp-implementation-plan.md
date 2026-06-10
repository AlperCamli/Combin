# Combin MVP - Supabase Implementation Plan

> **Current status (June 10, 2026):** the MVP backend has been migrated from
> Firebase to Supabase. This document is the current build sheet for the MVP.
> Backend flow details live in `docs/core-loop-backend-flow.md` and
> `docs/supabase-backend-flow.md`.

> **For coding agents:** execute phases in order. Each step should be small
> enough to verify independently. Do not reintroduce Firebase services unless the
> human explicitly asks for a Firebase rollback.

---

## What We're Building

Combin is an iOS-native AI stylist app. The MVP covers the **Daily Vibe Check**:
the user takes or selects a photo of an outfit, the app uploads it privately, and
the backend returns:

- A fast Stage 1 one-liner.
- A later Stage 2 tweak, style vector, and garment extraction.
- A saved look in the wardrobe.

The intended UX stays the same after the migration: Stage 1 appears first, Stage
2 fades in later, and the saved vibe-check / wardrobe state finalizes once the
backend persistence step completes.

Discover, Education, Outfit Planner, Daily Puzzle, affiliate integrations, and a
custom CMS remain out of scope for this MVP plan.

---

## Tech Stack

- **Client:** Swift / SwiftUI, iOS 17+.
- **Auth:** Supabase Auth with anonymous sign-in.
- **Database:** Supabase Postgres with Row Level Security.
- **Photo storage:** private Supabase Storage bucket `outfit-photos`.
- **Backend:** Supabase Edge Functions, Deno runtime.
- **AI provider:** Gemini, called only from the Edge Function.
- **Config:** `app_config` table for model names, prompts, and daily limits, with
  hardcoded backend fallbacks.
- **iOS config:** `Combin/Configuration/SupabaseConfig.plist` containing only
  `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`.

Firebase Auth, Firestore, Firebase Storage, Firebase Functions, Remote Config,
Analytics, Crashlytics, App Check, and Firebase AI Logic are no longer part of
the current MVP implementation.

---

## Architectural Invariants

1. No commerce, scoring, or streak mechanics in the vibe-check flow.
2. Voice is warm and specific, never preachy or salesman-like.
3. No body-related language anywhere. "You" is OK; "your body," "your shape,"
   "flattering," and similar framing are not.
4. The iOS app never contains Gemini keys or Supabase service-role keys.
5. The iOS app uploads photos only to private Supabase Storage paths under the
   signed-in user's uid: `{uid}/photos/{photoId}.jpg`.
6. All user rows must be protected by RLS with `user_id = auth.uid()`.
7. Storage objects must be private and scoped by first path segment matching
   `auth.uid()`.
8. The Edge Function owns Gemini orchestration, persistence, and wardrobe fan-out.
9. Stage 1 must be revealed as soon as it streams; Stage 2 must not block Stage 1.
10. Local demo mode must still work when Supabase config is missing or still
    contains placeholders.

---

## Repository Structure

```text
Combin/
+-- CombinApp.swift
+-- Configuration/
|   +-- SupabaseConfig.plist
|   +-- SupabaseConfig.swift
+-- Models/
|   +-- StyleVector.swift
|   +-- VibeCheck.swift
|   +-- WardrobeItem.swift
+-- Services/
|   +-- AuthService.swift
|   +-- PhotoUploadService.swift
|   +-- VibeCheckService.swift
|   +-- WardrobeService.swift
+-- Features/
|   +-- Camera/
|   +-- VibeCheckResult/
|   +-- Wardrobe/
+-- Screens/

supabase/
+-- config.toml
+-- seed.sql
+-- .env.example
+-- migrations/
|   +-- 202606080001_initial_supabase_cutover.sql
+-- functions/
|   +-- process-vibe-check/
|       +-- index.ts
|       +-- sse.ts
|       +-- sse_test.ts
+-- tests/
    +-- database.test.sql
```

---

# Phase 0 - Supabase Foundation

Goal: the iOS app can launch, create or restore an anonymous Supabase user, and
run in UI-only demo mode when config is absent.

## Step 0.1 - Supabase Project Setup

- Create the Supabase project for the app.
- Enable anonymous sign-ins in Supabase Auth.
- Apply migrations in `supabase/migrations/`.
- Seed `app_config` from `supabase/seed.sql`.
- Confirm private bucket `outfit-photos` exists with a 5 MiB limit and JPEG-only
  MIME type.

**Acceptance:** `supabase db reset` succeeds in a local Docker-backed Supabase
environment, and the dashboard shows the tables, policies, RPC, and bucket.

## Step 0.2 - iOS Configuration

- Put the public client values in `Combin/Configuration/SupabaseConfig.plist`:
  - `SUPABASE_URL`
  - `SUPABASE_PUBLISHABLE_KEY`
- Keep placeholders in source control; use real values only in local working
  copies or build-time secret injection.
- Do not add `SUPABASE_SERVICE_ROLE_KEY` or `GEMINI_API_KEY` to the app bundle.

**Acceptance:** with real values, the app initializes Supabase; with placeholders,
the app falls back to UI-only demo mode.

## Step 0.3 - Anonymous Auth

- `AuthService` restores the current Supabase session on launch.
- If no session exists, it signs in anonymously.
- Preserve app-facing state semantics:
  - `.loading`
  - `.signedIn(uid)`
  - `.unavailable`

**Acceptance:** a fresh install creates an anonymous Supabase user; relaunching
reuses the same session.

---

# Phase 1 - Core Vibe Check Loop

Goal: the user captures or selects an outfit photo, sees Stage 1 quickly, receives
Stage 2 later, and gets a persisted wardrobe-backed look.

## Step 1.1 - Camera And Picker

- Keep the existing SwiftUI camera / picker flow.
- Compress selected images to JPEG before upload.
- Keep the loading screen intentional and calm rather than a generic spinner.

**Acceptance:** shutter and gallery both pass compressed image data into the
vibe-check flow.

## Step 1.2 - Private Photo Upload

- `PhotoUploadService` uploads to Supabase Storage bucket `outfit-photos`.
- Path format: `{uid}/photos/{photoId}.jpg`.
- Continue using the local pending-upload queue for failures and retry on the
  next authenticated launch.

**Acceptance:** photos land in the private bucket under the signed-in user's uid,
and another user cannot read or write that path.

## Step 1.3 - Edge Function Invocation

- `VibeCheckService` calls authenticated Edge Function `process-vibe-check`.
- Request JSON:

```json
{
  "photoPath": "{uid}/photos/{photoId}.jpg",
  "device": {
    "os": "iOS ...",
    "model": "..."
  }
}
```

- The app must send the user's Supabase JWT.

**Acceptance:** unauthenticated calls fail, wrong-owner `photoPath` calls fail,
and valid calls start an SSE response.

## Step 1.4 - Backend Processing

`process-vibe-check` must:

- Validate request method, JSON shape, JWT, and photo path ownership.
- Claim a daily usage slot through `claim_daily_vibe_check(limit)`.
- Return HTTP `429` with `{ reason: "daily_limit", limit, upgradeAvailable: true }`
  when capped.
- Download the private storage object server-side.
- Validate MIME type and size.
- Call Gemini with inline image bytes.
- Run Stage 1 and Stage 2 in parallel.
- Read model names, prompt overrides, and daily limit from `app_config`, with
  hardcoded fallbacks.

**Acceptance:** mock mode (`GEMINI_MOCK=1`) exercises the same streaming and
persistence path without calling Gemini.

## Step 1.5 - Streamed Result UX

The Edge Function streams Server-Sent Events:

- `stage1`: `{ text, confidence, latencyMs }`
- `stage2`: `{ tweakText, styleVector, garments, latencyMs }`
- `saved`: `{ vibeCheckId, garmentsWritten, remaining }`

The app should:

- Reveal Stage 1 as soon as it arrives.
- Fade in Stage 2 when available.
- Treat `saved` as the persistence completion signal.
- Show rate-limit and network failures with friendly copy.

**Acceptance:** Stage 1 can render before Stage 2 or save completion; a saved
vibe-check appears in Wardrobe after the `saved` event.

## Step 1.6 - Persistence

The backend writes:

- One `vibe_checks` row.
- Zero or more `wardrobe_items` rows.
- One `daily_usage` counter update through the atomic RPC.

The iOS app reads:

- `vibe_checks` ordered by `created_at desc`.
- `wardrobe_items` ordered by `created_at desc`.
- private Storage images by `photo_path` using the signed-in session.

**Acceptance:** another authenticated user cannot read the first user's rows or
Storage objects.

---

# Phase 2 - Onboarding

Goal: onboarding wraps the already-working core loop without changing backend
contracts.

## Step 2.1 - Welcome And Trust

- Keep onboarding short.
- Explain that photos are private to the user's account.
- Do not mention backend implementation details in UI copy.

**Acceptance:** a first-time user reaches camera capture without needing to create
a permanent account.

## Step 2.2 - Permissions

- Ask for camera and photo-library access only when needed.
- Defer push notifications.
- Defer Sign in with Apple account linking.

**Acceptance:** denied permissions have recoverable UI states.

## Step 2.3 - First Vibe Check

- Reuse the Phase 1 capture, upload, stream, and save flow.
- Use warmer onboarding framing around the result.
- If the `saved` event reports at least one wardrobe item, show the handoff into
  Wardrobe.

**Acceptance:** first vibe-check produces a saved look and optional wardrobe
handoff without separate polling.

## Step 2.4 - Zero Garments On First Photo

If Stage 2 extracts zero garments on the first photo:

- Do not show the wardrobe handoff.
- Invite the user to retry with friendlier angle / lighting copy.
- Do not count this as an onboarding failure in the UI.

**Acceptance:** first-use zero-extraction feels recoverable and does not send the
user to an empty wardrobe.

---

# Phase 3 - Minimal Wardrobe

Goal: enough wardrobe functionality to prove persistence, image loading, and the
next-feature foundation.

## Step 3.1 - Tab Shell

- Keep a simple app shell with Vibe Check and Wardrobe.
- Defer richer Discover, Education, and Planner tabs.

**Acceptance:** the user can return to saved looks after completing a vibe-check.

## Step 3.2 - Looks View

- Query `vibe_checks` from Supabase.
- Display Stage 1 text, tweak text when present, created date, and private photo.
- Use `StorageImage(path:)` for private Supabase Storage downloads.

**Acceptance:** saved looks render after relaunch, using the signed-in Supabase
session.

## Step 3.3 - Wardrobe Items

- Query `wardrobe_items` from Supabase.
- Show a minimal list or grouped view of extracted garments.
- Keep manual correction, filters, and per-garment crops out of MVP.

**Acceptance:** extracted garments from Stage 2 are visible somewhere in Wardrobe.

---

# Backend Data Model

Schema v2 (detailed outfit analysis, adopted from the human's rate-fit prototype
without its scoring mechanics) is documented in `docs/data-model.md`. In brief:

- `app_config`: server-readable JSON config (models, prompts, daily limit,
  temperature). Never contains secrets.
- `vibe_checks`: one row per processing attempt — one-liner, tweak, longer-read
  `summary`, 12-axis `style_vector`, `style_tags`, `occasion_fit`, `palette`,
  `photo_quality`, `thumb_path`, model provenance, latency fields.
- `wardrobe_items`: Stage 2 garment fan-out — category, type, subtype, color +
  `colors` breakdown, pattern, material_guess, fit, confidence, stylist comment.
- `daily_usage`: daily counters used by `claim_daily_vibe_check(limit)`. The app
  should not write this table directly.

---

# Test Plan

## Backend

- Run `supabase db reset`.
- Run SQL/RLS tests in `supabase/tests/database.test.sql`.
- Verify own-user reads and writes are allowed.
- Verify other-user and unauthenticated access are denied.
- Verify `claim_daily_vibe_check(limit)` is atomic and caps correctly.
- Run Deno tests for SSE helpers and Edge Function validation.
- Run Edge Function locally with `GEMINI_MOCK=1`.

## iOS

- Build with Xcode or:

```bash
xcodebuild -project Combin.xcodeproj -scheme Combin -destination 'platform=iOS Simulator,name=iPhone 16' build
```

- Verify UI-only mode when `SupabaseConfig.plist` contains placeholders.
- Verify anonymous sign-in with real Supabase config.
- Verify upload, streamed Stage 1, streamed Stage 2, saved look, wardrobe query,
  and private image loading.
- Verify failed uploads remain in the local pending queue and retry later.

## Manual Acceptance

- A fresh install creates a Supabase anonymous user.
- A vibe-check stores one private photo and one `vibe_checks` row.
- Stage 2 creates zero or more `wardrobe_items`.
- Another authenticated user cannot read the first user's rows or photos.
- Setting `daily_vibe_check_limit` to `2` rejects the third request with the
  upgrade payload.

---

# Secret And Config Rules

- `SUPABASE_URL`: iOS plist is OK.
- `SUPABASE_PUBLISHABLE_KEY`: iOS plist is OK.
- `SUPABASE_SERVICE_ROLE_KEY`: backend/server-only; do not put in iOS, docs with
  real values, commits, screenshots, or logs.
- `GEMINI_API_KEY`: Supabase Edge Function secret only; do not put in iOS.
- `supabase/.env.example`: committed template with empty values only.
- `supabase/.env`, `supabase/.env.*`, `.env`, and `.env.*`: ignored local secret
  files.

For deployed Edge Functions, set secrets in Supabase:

```bash
npx supabase secrets set GEMINI_API_KEY=...
```

If a future backend path needs the service-role key, store it as a Supabase
secret and use it only inside Edge Functions. Prefer caller-JWT Supabase clients
plus RLS unless service-role access is explicitly required.

---

# What's Deliberately Not In This Plan

- Firebase services or dual-write migration.
- Firebase data import.
- Crash reporting replacement.
- Commerce, affiliate links, or subscription purchase flow.
- Discover tab content.
- Education tab content.
- Outfit Planner flow.
- Daily Puzzle engine.
- Manual wardrobe correction.
- Per-garment image crops.
- Style vector similarity search.
- Push notifications.
- Sign in with Apple linking.
- Localization beyond English.
- iPad-specific layouts.

Each should get its own plan after the Supabase MVP loop is stable.

---

# Voice And Copy Guide

The voice is **a fashion-literate friend who texted back fast.** Warm, specific,
confident, sometimes funny. Humor is kindness, never ridicule.

## Words To Avoid

- "Wrong," "incorrect," "bad," "mistake," "error," "fail," "good try."
- "Should," "must," "need to."
- "Beautiful," "stunning," "gorgeous" as empty praise.
- "Okay," "fine," "not bad."
- Anything about "your body," "your shape," "flattering," or "for your figure."

## Sample One-Liners

When the outfit works:

- "Quiet confidence - the kind people remember without knowing why."
- "This is doing the work. You can leave."
- "Three textures, one mood. That's the trick."

When the outfit needs a tweak:

- "Almost there - one more anchoring piece and this lands."
- "The colors are good friends. The shapes are still working it out."

When the outfit is uncertain:

- "I'm 50/50 on this one - the silhouette works but the proportions are tricky."

## Loading Phrases

- "looking closely..."
- "reading the outfit..."
- "thinking it over..."
- "checking the proportions..."
- "finding the right words..."

## Error And Edge Case Copy

No outfit visible:

- "I can't quite see the outfit - want to try another angle?"

Low light:

- "Hard to read in this light, but here's what I caught."

Network failure:

- "Lost the connection for a sec. Pull down to try again."

Rate limit hit:

- "You've had a lot of vibe-checks today. Try again tomorrow."

Zero garments extracted on first photo:

- "This one was a little tricky to read - want to try another photo? Sometimes a
  different angle or better light makes all the difference."

---

# Pre-Launch Security Checklist

- [ ] Supabase Auth anonymous sign-in enabled intentionally.
- [ ] RLS enabled on every app table.
- [ ] `vibe_checks`, `wardrobe_items`, and `daily_usage` policies scope access to
      `auth.uid()`.
- [ ] `app_config` contains no secrets.
- [ ] Storage bucket `outfit-photos` is private.
- [ ] Storage policies scope object access by first path segment matching
      `auth.uid()`.
- [ ] Edge Function has `verify_jwt = true`.
- [ ] Edge Function validates method, JSON shape, caller uid, photo path
      ownership, MIME type, and file size.
- [ ] Gemini calls happen only in the Edge Function.
- [ ] `GEMINI_API_KEY` is set as a Supabase secret.
- [ ] No service-role key is bundled in iOS.
- [ ] Daily limit behavior is verified, including the `429` upgrade payload.
- [ ] No image bytes, prompt bodies, JWTs, service-role keys, or Gemini responses
      with sensitive user data are logged.
- [ ] A red-team pass checks that extracting the app binary does not reveal
      backend-only secrets.

---

# Decisions Resolved

1. **Backend platform:** Supabase Edge Functions, not a separate Node API.
2. **Data store:** Supabase Postgres with RLS, not Firestore.
3. **Storage:** private Supabase Storage bucket `outfit-photos`.
4. **Auth:** Supabase anonymous sign-in for MVP.
5. **AI boundary:** Gemini stays as provider, but all Gemini calls are backend-only.
6. **Migration shape:** fresh Supabase cutover; no Firebase import and no dual
   writes.
7. **Rate limiting:** atomic SQL RPC `claim_daily_vibe_check(limit)`.
8. **Wardrobe extraction:** Stage 2 garments fan out into `wardrobe_items`; no
   Storage-trigger polling race.
9. **Taste calibration:** deferred until style axes are finalized.
10. **Style vector axes:** locked to the twelve axes from the human's rate-fit
    prototype (`outfit_analysis`): formality, trendiness, boldness, colorfulness,
    cohesion, layering_complexity, accessory_density,
    silhouette_relaxed_vs_tailored, seasonality_warmth, contrast,
    monochrome_index, neutral_ratio. Internal-only, 0-100, never user-facing.
