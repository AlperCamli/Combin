# Combin MVP — Implementation Plan for Claude Code

> **For the Claude Code agent**: this is your build sheet. Execute phases in order. Each step is sized to be a self-contained unit of work. Stop and ask the human before moving between phases. Do not skip ahead — Phase 1 must be working end-to-end before Phase 2 begins, because Phase 2 wraps onboarding around the core loop and assumes it works.
>
> The six original `[DECISION POINT]` items have all been resolved (see "Decisions resolved" section at the bottom). The one remaining pending decision is the final list of style-vector axes — the human will signal when they're ready to lock those in, and at that point you should pause and ask for the exact axis names and rubric.

---

## What we're building

Combin is an iOS-native AI stylist app. The core loop — and the only feature this MVP plan covers — is the **Daily Vibe Check**: the user takes a photo of their outfit, and within ~3 seconds the app responds with a warm, specific, fashion-literate one-liner about it (and optionally a tweak suggestion).

The MVP plan stops there. Discover, Education, Outfit Planner, Daily Puzzle, affiliate integrations, and the custom CMS are **out of scope** for this plan. Build them later, after the core loop is shipping and we have user data.

---

## Tech stack (locked)

- **Client**: Swift / SwiftUI, iOS 17+ (deployment target iOS 17.0)
- **Auth**: Firebase Auth, Sign-in-with-Apple, anonymous-first
- **Database**: Firestore (with offline persistence enabled)
- **Photo storage**: Cloud Storage for Firebase
- **AI**: Firebase AI Logic SDK → Vertex AI Gemini backend
    - Stage 1: `gemini-3.1-flash-lite` (model name in Remote Config)
    - Stage 2: `gemini-3.5-flash` (model name in Remote Config)
- **Server-side code**: Cloud Functions for Firebase, TypeScript on Node.js 20
- **Security**: App Check with DeviceCheck provider + replay-attack protection
- **Analytics**: Firebase Analytics + Crashlytics
- **Feature flags / model names**: Firebase Remote Config

No Sanity, no SwiftData layer on top of Firestore, no custom backend server, no Vertex AI Vector Search (we use Firestore Vector Search for the style feature vectors), no separate embedding model (style scores are part of Gemini's structured output).

---

## Architectural invariants (don't violate these)

1. **No commerce, no scoring, no streaks in the vibe-check flow.** Just the one-liner.
2. **Voice is warm and specific, never preachy or salesman-like.** See the voice guide section at the bottom.
3. **Photos never leave Cloud Storage to anywhere except Vertex AI Gemini** (and only as a transient `gs://` URI, never persisted by us elsewhere).
4. **App Check is mandatory** on Firestore, Storage, and Firebase AI Logic — not just one of them.
5. **All Firestore writes scoped to `request.auth.uid`** in Security Rules, with default-deny catchall.
6. **Model names live in Remote Config, never hardcoded.** Same for any prompt template that might need tuning post-release.
7. **Stage 1 must return within ~1.5 seconds.** If a change makes it slower, that change is wrong.
8. **No body-related language anywhere.** "You" is OK; "your body," "your shape," "flattering," etc. is not.

---

## File structure expectation

```
combin-ios/                          # Xcode project root
├── Combin/
│   ├── CombinApp.swift              # @main entry point
│   ├── Configuration/
│   │   ├── GoogleService-Info.plist
│   │   └── FirebaseConfig.swift     # AI Logic, Remote Config setup
│   ├── Models/
│   │   ├── VibeCheck.swift
│   │   ├── WardrobeItem.swift
│   │   └── StyleVector.swift
│   ├── Services/
│   │   ├── AuthService.swift
│   │   ├── PhotoUploadService.swift
│   │   ├── VibeCheckService.swift   # the Gemini orchestrator
│   │   └── WardrobeService.swift
│   ├── Features/
│   │   ├── Camera/
│   │   ├── VibeCheckResult/
│   │   ├── Onboarding/
│   │   └── Wardrobe/
│   └── DesignSystem/
│       ├── Typography.swift
│       ├── Colors.swift
│       └── Components/
└── CombinTests/

combin-functions/                    # Cloud Functions project
├── src/
│   ├── index.ts
│   ├── extractGarments.ts           # photo upload trigger
│   ├── rateLimit.ts                 # per-user call cap
│   └── prompts/
│       ├── stage1.ts
│       ├── stage2.ts
│       └── extraction.ts
├── firestore.rules
├── storage.rules
├── firestore.indexes.json
└── package.json
```

---

# Phase 0 — Foundation

Goal: a runnable iOS app skeleton connected to a Firebase project with security enforced, ready for the core loop to be built on top.

## Step 0.1 — Create the Firebase project

- Create a new Firebase project named `combin-prod` (and `combin-dev` for development).
- Enable: Authentication, Firestore, Cloud Storage, Cloud Functions, App Check, Remote Config, Analytics, Crashlytics.
- In Firestore: choose **Native mode**, region `eur3` (EU multi-region, Frankfurt + Netherlands). This is the MVP launch region.
- **Post-MVP roadmap note**: once we're ready to optimize for US users, we'll need to either migrate to a different region or set up a second Firebase project with replication. Don't try to handle multi-region routing in the MVP code — assume single-region EU for now, and architect the data model so it can be replicated cleanly later (i.e., no region-baked-in fields).
- Set up Cloud Billing with a hard cap budget alert at $500/month for dev, configurable for prod.

**Acceptance**: Firebase console shows all six services enabled. Billing alerts configured.

## Step 0.2 — iOS Xcode project skeleton

- Create a new SwiftUI iOS app, deployment target iOS 17.0, portrait-only.
- Add Firebase iOS SDKs via Swift Package Manager:
    - `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`, `FirebaseAI` (Firebase AI Logic), `FirebaseAppCheck`, `FirebaseRemoteConfig`, `FirebaseAnalytics`, `FirebaseCrashlytics`.
- Drop in `GoogleService-Info.plist` from the Firebase console.
- In `CombinApp.swift`, initialize Firebase in the App's `init()`.
- Enable Firestore offline persistence (this is the default on iOS, but verify in code).

**Acceptance**: App launches without crashing, prints "Firebase configured" to console.

## Step 0.3 — Cloud Functions TypeScript skeleton

- Run `firebase init functions`, choose TypeScript, Node.js 20.
- Set up ESLint and Prettier.
- Create a hello-world callable function and deploy it to confirm the pipeline works.
- Install dependencies: `firebase-admin`, `firebase-functions` (2nd gen).

**Acceptance**: `firebase deploy --only functions` succeeds. Test the hello-world function from `curl` or the Firebase console.

## Step 0.4 — App Check setup

- In Firebase console: enable App Check, configure DeviceCheck as the iOS provider.
- In Xcode: add the DeviceCheck capability to the app's entitlements.
- In `CombinApp.swift`'s `init()`, configure App Check **before** Firebase initialization:
    ```
    AppCheck.setAppCheckProviderFactory(DeviceCheckProviderFactory())
    FirebaseApp.configure()
    ```
- Enable **replay-attack protection** in the App Check settings for AI Logic.
- Set App Check to **enforce** (not just monitor) on Firestore, Storage, and AI Logic.

**Acceptance**: App can read/write to Firestore. Calls from a script without App Check are rejected.

## Step 0.5 — Firestore Security Rules baseline

Write `firestore.rules` with default-deny and per-user scoping:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
      match /{collection}/{document=**} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }
    // Default deny everything else
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Same shape for `storage.rules`:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId
                         && request.resource.size < 5 * 1024 * 1024
                         && request.resource.contentType.matches('image/.*');
    }
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

Set up Firebase Emulator for local rules testing. Write at least 5 rules unit tests covering: own-user-read-allowed, other-user-read-denied, unauthenticated-denied, non-image-upload-denied, oversized-upload-denied.

**Acceptance**: All 5 rules tests pass against the emulator. Rules deployed to dev project.

## Step 0.6 — Auth: anonymous bootstrap

- Create `AuthService.swift`.
- On app cold start, if no current user, sign in anonymously via `Auth.auth().signInAnonymously()`.
- Store the `uid` in `@Published` state for the rest of the app to observe.
- Add a simple loading state ("Setting things up...") visible only on the very first launch; subsequent launches use the persisted anonymous session.

**Acceptance**: App launches → anonymous user created → uid printed to console → on relaunch, same uid persists.

---

# Phase 1 — Core Vibe Check Loop

Goal: a user opens the app, points the camera at their outfit, taps the shutter, and within ~3 seconds gets a warm one-liner. Within ~5 seconds, an optional tweak appears below.

This is the heart of the product. Every other feature is built around this loop.

## Step 1.1 — Camera capture screen

- Create `CameraView.swift` in `Features/Camera/`.
- Use `AVCaptureSession` with a `UIViewRepresentable` wrapper for the preview layer.
- Full-screen camera preview, portrait only.
- Single shutter button at the bottom center — circular, generous tap target (~80pt).
- Top-left: small "X" or back affordance (does nothing in MVP; reserve for navigation later).
- Top-right: small gallery icon → opens `PHPickerViewController` for choosing an existing photo.
- A soft, low-contrast frame guide in the center suggesting where the outfit should sit. Not enforced.

**Acceptance**: Camera preview visible. Shutter tap captures a still image. Gallery icon opens picker. Captured `UIImage` is passed to the next screen.

## Step 1.2 — Photo capture handoff

- After capture, the `UIImage` is compressed to JPEG quality 0.75 at max 2048px long edge.
- A "Thinking..." loading screen appears immediately — see Step 1.4 for its design.
- The photo bytes are passed to `PhotoUploadService.upload(image:)` which returns the `gs://` URI once upload completes.

**Acceptance**: Tapping shutter transitions to loading screen. Photo is compressed correctly (verify file size < 400KB typical).

## Step 1.3 — Photo upload to Cloud Storage

- Create `PhotoUploadService.swift`.
- Upload path: `users/{uid}/photos/{photoId}.jpg` where `photoId` is a UUID.
- Use Firebase Storage's `putData(_:metadata:)` with `contentType: "image/jpeg"`.
- Return the `gs://` URI on success.
- On failure: retain photo in a local pending queue (use simple `FileManager` storage in app's documents directory + a UserDefaults list of pending uploads). Retry next app launch.

**Acceptance**: Photo lands in Cloud Storage at the correct path. Verify in Firebase console. Storage Rules reject upload attempts to other users' folders.

## Step 1.4 — The "Thinking..." loading screen

Per the user-journeys brief, this should "feel intentional, not a generic spinner." Build it as:

- Off-white / paper background, same as the rest of the app.
- A subtle, slow-moving visual element — a single line that gently writes itself across the screen, or three dots that breathe — but NOT a standard spinner.
- A low-contrast line of text that cycles through ~5 phrases: "looking closely…", "thinking it over…", "reading the outfit…", etc. (full list in Voice section at bottom of this doc).
- No progress bar, no percentage.

**Acceptance**: Screen renders, animation runs smoothly at 60fps on iPhone 12+, text cycles through phrases at a calm pace (~2.5s per phrase).

## Step 1.5 — Firebase AI Logic Stage 1 call

This is the fast path — the one-liner.

- Create `VibeCheckService.swift`.
- Initialize Firebase AI Logic with the Vertex AI backend:
    ```swift
    let model = FirebaseAI.firebaseAI(backend: .vertexAI())
        .generativeModel(modelName: RemoteConfig.shared.string(forKey: "stage1_model"))
    ```
- The Stage 1 prompt is short and singular. Stored in Remote Config under `stage1_prompt_template`. The prompt asks Gemini for:
    - A single sentence (12–22 words) in the vibe-check voice.
    - Structured JSON output: `{ "vibe_check": "...", "confidence": 0.0–1.0 }`.
- Input: the photo as a `gs://` URI (Firebase AI Logic with Vertex AI backend supports Cloud Storage URIs directly).
- Use Gemini's structured output mode (`responseSchema`) so the response is always valid JSON.
- **Stream the response** for time-to-first-token.

**Acceptance**: Stage 1 returns a one-line vibe-check within 1.5s on a decent connection. Logs latency to Firebase Analytics. Response is always valid JSON matching the schema.

## Step 1.6 — Display the vibe-check result

- Create `VibeCheckResultView.swift`.
- Hierarchy:
    - The one-liner: large serif (or whatever the design system defines), centered, generous vertical space above and below.
    - Below: an empty placeholder for the Stage 2 tweak card (loads in async — see 1.7).
    - Bottom action row: small "Save" icon (does nothing yet), "Share" icon (does nothing yet), "Try another angle" (re-opens camera).
- The one-liner appears with a gentle fade-in as Stage 1 streams in — character-by-character or word-by-word, whichever feels less stutter-prone.
- The tab bar is hidden on this screen — it's a focused, immersive moment.

**Acceptance**: Result screen renders with proper hierarchy. Stage 1 text streams in smoothly. Tab bar (when it exists in Phase 3) is hidden here.

## Step 1.7 — Stage 2 parallel call

Fire Stage 2 **in parallel with Stage 1**, not after. Both calls start the moment the photo upload completes.

- Stage 2 model: `gemini-2.5-flash` (from Remote Config).
- Stage 2 prompt asks for:
    - An optional tweak suggestion (one sentence, may be empty if the outfit doesn't need one).
    - **The style feature vector** — a set of named scores from 0–100 that Gemini derives from looking at the photo. The final list of scoring axes is **NOT decided yet** and will be refined through testing. **Start with this placeholder set of 5 axes for early prototyping**: `vibe`, `formality`, `colorfulness`, `cohesion`, `statement_strength`. These are starter axes — expect to iterate.
    - **Important note for the agent**: when the human is ready to lock the final axis list (typically after a few weeks of prototype testing), they will tell you. At that point, **stop and ask the human for the exact axis names and their scoring rubric definitions** before changing this prompt. Do not invent or expand the axis list on your own.
    - A short structured list of extracted garments (used by the wardrobe builder, see Step 1.9).
- Response schema (JSON):
    ```json
    {
      "tweak": "string or null",
      "style_vector": { "vibe": 70, "formality": 78, "colorfulness": 34, "cohesion": 85, "statement_strength": 40 },
      "garments": [
        { "category": "outerwear", "type": "trench coat", "color": "camel", "confidence": 0.9 },
        ...
      ]
    }
    ```
- The image analysis is done entirely by Gemini — it reads the photo and assigns each score directly. We do not compute these scores ourselves anywhere.
- When Stage 2 returns, populate the tweak card below the one-liner with a gentle fade-in. If `tweak` is null, the card stays absent — that's fine, "you nailed it" is the implicit message.

**Acceptance**: Stage 2 returns within ~3.5s on average. Tweak card appears smoothly. JSON always validates against the schema (use Gemini's structured output mode).

## Step 1.8 — Save the vibe-check to Firestore

When both stages return, write the vibe-check document:

- Path: `users/{uid}/vibeChecks/{vibeCheckId}`
- Document shape:
    ```typescript
    {
      photoStoragePath: "gs://...",
      stage1Text: "...",
      stage1Latency: 1.2,
      tweakText: "..." | null,
      styleVector: { vibe: 70, formality: 78, colorfulness: 34, cohesion: 85, statement_strength: 40 },  // starter axes — expect to iterate
      createdAt: Timestamp,
      device: { os: "iOS 17.4", model: "iPhone 15" },
      stage2Latency: 3.1
    }
    ```
- Use Firestore's offline persistence — the write succeeds locally immediately even if offline; it'll sync when network returns.

**Acceptance**: Vibe-check document appears in Firestore. Visible in console. Survives offline → online transition.

## Step 1.9 — Cloud Function: garment extraction trigger

In `combin-functions/src/extractGarments.ts`:

- Trigger: Cloud Storage `onObjectFinalized` for paths matching `users/*/photos/*.jpg`.
- Parse the `uid` and `photoId` from the path.
- The Stage 2 call from the client already extracted garments and saved them to the vibe-check document. The Cloud Function's job is now smaller: **read the garments array from the vibe-check document, write each garment as a separate document to `users/{uid}/wardrobe/{itemId}`**.
- **No cropping.** Wardrobe items do not get individual cropped thumbnails. Each item references the full source photo via `sourcePhotoStoragePath`, and the wardrobe UI displays the source photo (or a uniform-sized region of it) rather than an extracted crop. This is a deliberate choice to avoid the computational cost and crop-quality risk of per-garment image processing.
- Each wardrobe item document:
    ```typescript
    {
      sourceVibeCheckId: "...",
      sourcePhotoStoragePath: "gs://...",
      category: "outerwear",
      type: "trench coat",
      color: "camel",
      attributes: { ... },
      status: "active",
      createdAt: Timestamp
    }
    ```
- Use the Admin SDK (which bypasses Security Rules — that's expected).

**Acceptance**: Uploading a photo to Cloud Storage triggers the function. Garments from the vibe-check appear in `users/{uid}/wardrobe/`. Function logs to Cloud Logging on success and failure.

## Step 1.10 — Rate limiting infrastructure (build the scaffolding, don't enforce hard limits yet)

Build the rate-limiting machinery so we can turn the knobs at launch, but **don't set strict limits during development and testing**. The point is to have the lever ready, not to throttle the team's own testing or the first wave of beta users.

- Implement rate limiting as a **Callable Cloud Function** `checkRateLimit` (preferred over Firestore-counters-with-rules — easier to evolve, easier to log, easier to bypass for testing accounts).
- Track per-user usage in `users/{uid}/usage/daily` documents:
    ```typescript
    {
      date: "2026-06-02",
      vibeCheckCount: 12,
      lastVibeCheckAt: Timestamp
    }
    ```
- The function reads the current limit from **Firebase Remote Config** under the key `daily_vibe_check_limit`. **Default value during development: 1000** (effectively unlimited). The number gets tightened later, near launch, once we have real usage data.
- The client calls `checkRateLimit` before initiating Stage 1; if rejected, show a friendly message — but for now, with the limit at 1000, no one will see it during testing.
- **Subscription hook (for later, not now)**: this rate-limit boundary is the natural surface for a subscription offer. When a future free-tier user hits their limit, the rejection response should include enough info for the client to show "You've used your free vibe-checks for today. Upgrade to Plus for more, or come back tomorrow." We're not building the subscription flow in MVP, but the rate-limit function should return a structured response (e.g., `{ allowed: false, reason: "daily_limit", limit: 5, upgradeAvailable: true }`) so adding the upgrade prompt later is a UI-only change.
- Log every rate-limit decision (allowed and rejected) to Cloud Logging so we can analyze usage patterns before setting real limits.

**Acceptance**: Function deployed and callable. With `daily_vibe_check_limit` set to 1000 in Remote Config, all test calls return `allowed: true`. Manually setting the limit to 2 in Remote Config and making 3 vibe-checks shows the 3rd rejected. Limit returns to 1000 for ongoing testing.

## Step 1.11 — End-to-end test of the loop

Manually test the full loop on a real device:

1. App cold launch.
2. Camera appears.
3. Take a photo.
4. Loading screen appears immediately.
5. Stage 1 one-liner streams in within ~1.5s.
6. Stage 2 tweak (if present) fades in within ~3.5s.
7. Vibe-check saved to Firestore.
8. Cloud Function fires; wardrobe items appear in Firestore within ~10s.

Repeat 10 times with varied photos: full-body, mirror selfies, gallery uploads, low-light, no-outfit-visible, jacket-only, full outfit.

**Acceptance**: All 10 runs complete the loop. Failure modes (no outfit visible, blurry, etc.) return graceful messages, not crashes. P50 latency to first sentence under 1.8s, P50 to full output under 4s.

---

## **STOP HERE.** Before moving to Phase 2:

- All Phase 1 acceptance criteria met.
- Latency budget verified on real device, real network.
- Security rules tested.
- The human has reviewed the actual vibe-check output and signed off on the voice quality. Ask before proceeding.

---

# Phase 2 — Onboarding

Goal: wrap a 60-second onboarding flow around the working core loop. The user goes from app-install to first vibe-check delivered, in under 2 minutes, feeling like they've been treated with care.

## Step 2.1 — Welcome screen

- One screen, one sentence, one CTA.
- Copy: *"Your stylist in your pocket. Honest when you ask, kind every time."*
- Subtle hero visual (typography-focused; no stock photography).
- CTA: "Get started" — taps to Step 2.2.

**Acceptance**: Renders cleanly. Single tap advances.

## Step 2.2 — Trust & privacy

This screen carries more weight than any other in onboarding. Get it right.

- Headline: *"About your photos."*
- Body (concise, plain language, NOT legalistic):
    > *"Your photos go to Google's AI to read your outfit. They're not sold, not used for ads, not used to train anyone's model. You can delete any photo, or all of them, any time."*
- Two CTAs at the bottom: "Got it" and "Tell me more" (the second expands inline with one more paragraph of detail — does not navigate away).

**Acceptance**: Renders, expansion works inline. No external links.

## Step 2.3 — Taste calibration **[DEFERRED]**

**Skip this step in MVP.** Taste calibration depends on the final style-vector axes (the same axes referenced in Step 1.7). Until those axes are settled through prototype testing, the calibration cards have nothing meaningful to calibrate *against* — we'd be collecting preferences on a rubric we haven't defined yet.

When the style axes are finalized later (Step 1.7 covers when the agent should ask), we'll come back and build this screen. At that point it'll need:
- A card set chosen by fashion-editorial that spans the relevant style-axis ranges.
- A multi-select tap UI.
- Storage of selections at `users/{uid}/tastePreferences`.

For now, the onboarding flow skips directly from Step 2.2 (Trust & Privacy) to Step 2.4 (Permissions). The user goes through onboarding without seeding any taste signal — the AI will calibrate over time through use.

**Acceptance**: Onboarding flow skips this screen cleanly. No dead route. No broken navigation.

## Step 2.4 — Permissions

- Camera and Photo Library permissions, requested with context:
    > *"To read your outfit, we need to see it. Camera for new photos, Photos for ones you already took."*
- Standard iOS permission prompts.
- If denied, the flow continues; first-vibe-check screen handles the denied case gracefully.
- **Defer notification permission** — do NOT ask here. Asked later after the user's third vibe-check, per the UX designer's note.

**Acceptance**: Permissions requested. Denial handled.

## Step 2.5 — First photo capture (with extra-warm framing)

- Reuse the `CameraView` from Phase 1.
- Add a one-time low-contrast hint above the shutter: *"Show me what you're wearing today."*
- Equally prominent gallery affordance: *"or pick one from your photos."*
- A small caption: *"Don't worry — someone else can take the photo for you. Just make sure the outfit's visible."*

**Acceptance**: Reuses existing camera. Hint shows on first capture only. Gallery picker works.

## Step 2.6 — First vibe-check (with onboarding handoff line)

- Use the existing Stage 1 + Stage 2 flow from Phase 1.
- **One special-case behavior for the first vibe-check only**: after both stages complete and the result is displayed, append a low-contrast line below the action row:
    > *"I just learned a few pieces of your closet. Want to see?"*
- Tapping the line navigates to the (minimal) Wardrobe screen — see Phase 3.
- Dismissing (swipe down or tap anywhere else) lands on the home camera screen.

**Acceptance**: First-vibe-check delivers the result. Handoff line appears only on first run. Tap navigates to wardrobe; dismiss returns to camera.

## Step 2.7 — Edge case: zero garments extracted on first photo

If the first vibe-check returns zero extracted garments (bad lighting, weird crop, only face visible, no clear outfit), the handoff line in Step 2.6 must NOT appear — it would be meaningless without garments to show. **The first vibe-check is the highest-stakes moment in retention**, so the right response is to *invite a retry*, not to send the user away.

Instead of the handoff line, show this card directly below the result:

> *"This one was a little tricky to read — want to try another photo? Sometimes a different angle or better light makes all the difference."*
>
> [Try another photo] [Skip for now]

Behavior:
- **"Try another photo"** → re-opens the camera (or photo picker) immediately. The user takes/picks another photo, which fires a fresh Stage 1 + Stage 2 + extraction cycle. **No limit on retries during onboarding** — let the user try as many times as they want until extraction succeeds, or until they choose to skip. Every retry is a full new Gemini call; that's fine, the per-user testing cost is negligible and onboarding success is what matters.
- **"Skip for now"** → lands the user on the home camera screen without the handoff. The wardrobe is empty but the app is fully functional; they can take more vibe-checks later.
- If the retry succeeds (garments extracted), show the normal handoff line: *"I just learned a few pieces of your closet. Want to see?"*

Determining whether extraction succeeded:
- **Option A (recommended)**: poll the wardrobe collection for up to 5 seconds after Stage 2 returns. If items appear → show the handoff line. If not → show the retry card.
- **Option B**: convert the extraction function from a Storage trigger to a Callable function for the first-photo case only, and the client awaits its return.

Go with **Option A** for MVP — simpler, doesn't require duplicating function logic, and 5 seconds is well within human patience tolerance after a Stage 2 response has already landed.

**Acceptance**: When garments are extracted → handoff line appears. When zero garments are extracted → retry card appears with both buttons functional. Retry fires a fresh full vibe-check cycle. Skip lands cleanly on the home camera.

---

## **STOP HERE.** Before moving to Phase 3:

- The full onboarding-to-first-vibe-check flow completes in under 2 minutes on a real device.
- The handoff line correctly handles the zero-extraction case.
- The voice/copy has been reviewed by the human and signed off.

---

# Phase 3 — Just enough scaffolding for the next features

Goal: the bare minimum tab structure and wardrobe view to support the onboarding handoff and let the user navigate. **Don't build the full features here** — just enough to make the app feel coherent and let future phases plug in.

## Step 3.1 — Tab bar shell

- 5-tab bottom navigation per the UX designer's note:
    1. Discover (placeholder screen: "Coming soon — fashion catalogue.")
    2. Education (placeholder screen: "Coming soon — daily insights and puzzles.")
    3. + (center, distinct, accent-colored, raised) → opens the camera modal
    4. Outfit Planner (placeholder: "Coming soon — plan an outfit for tonight.")
    5. Wardrobe (working — see Step 3.2)
- Tap behavior per the spec: tapping a tab is instant, each tab preserves its scroll position, the + button opens the camera as a full-screen modal that slides up.
- Tab bar hidden during the camera flow and the vibe-check result screen.

**Acceptance**: All 5 tabs visible. Tabs 1, 2, 4 show placeholders. The + tab opens the camera. Tab 5 (Wardrobe) is functional.

## Step 3.2 — Wardrobe tab (minimal "Looks" view)

For now, the Wardrobe tab shows a single view: the photo grid ("Looks"). Items mode is out of scope for MVP.

- 3-column photo grid, most recent vibe-check photos first.
- Tap a photo → simple full-screen view of the photo + the one-liner that was given for it.
- First-visit framing copy at the top (per the UX designer's note):
    > *"This is what I caught from your photo. Every vibe-check adds to it."*
- Below the grid, another low-contrast line (first-visit only):
    > *"Keep taking vibe-checks and this fills in. After a couple of weeks, I'll start spotting things you already own."*

**Acceptance**: Wardrobe shows a grid of recent vibe-check photos. First-visit framing appears once and disappears on second visit. Tap-to-view works.

## Step 3.3 — Deferred notification permission ask

After the user's third successful vibe-check (count visible in Firestore as a derived value or stored on the user document), show an inline prompt below the result screen's action row:

> *"Want a small nudge tomorrow morning, before you leave?"*
> [Yes, just one] [Not now]

- Yes → trigger the standard iOS notification permission prompt + register FCM token.
- Not now → record dismissal; ask again in 7 days, then never via this surface.

**Acceptance**: Prompt appears on the 3rd vibe-check, never before. Yes flow registers FCM. Not now respects cooldown.

## Step 3.4 — Sign-in-with-Apple linking (deferred trigger)

The user has been anonymous all along. After the user has used the app for 3+ sessions OR has 5+ vibe-checks, surface a gentle prompt (in settings or as a one-time inline card):

> *"Sign in so your wardrobe stays with you if you change phones."*

Use Firebase Auth's `linkWithCredential` to upgrade the anonymous account to a Sign-in-with-Apple one — no data loss, same `uid`.

**Acceptance**: Sign-in flow works. Anonymous data carries over.

---

# What's deliberately NOT in this plan

Don't build these now. They're out of scope:

- Discover tab content (fashion catalogue, brand pages, click-outs)
- Education tab content (Daily Insight, Daily Puzzle, deep-dives)
- Outfit Planner flow (context capture, suggestions, affiliate "Suggested items" surface)
- Skimlinks / Awin affiliate integration
- Daily Puzzle evaluation engine
- Wardrobe Items view (toggle, attribute filters, manual correction)
- Wardrobe inline correction from the vibe-check result
- Custom CMS for editorial content
- Style vector similarity search (Firestore Vector Search) — the vectors are being stored, but no search feature is built on them yet
- Multiple-device sync edge cases beyond what Firestore offline persistence gives us for free
- Localization beyond English
- iPad layout

Each of these will be its own plan after the MVP is in TestFlight.

---

# Voice and copy guide for any user-facing strings

The voice is **a fashion-literate friend who texted back fast.** Warm, specific, confident, sometimes funny — humor as kindness, never as ridicule.

**Words to avoid throughout:**
- "Wrong," "incorrect," "bad," "mistake," "error," "fail," "good try" — no school-test framing. Use direction language.
- "Should," "must," "need to" — command voice. Use "try," "consider," "what about."
- "Beautiful," "stunning," "gorgeous" — empty enthusiasm. Use specific observations.
- "Okay," "fine," "not bad" — damning faintness.
- Anything about "your body," "your shape," "flattering," "for your figure" — body-language is out, full stop.

**Sample one-liners (these are NOT for prompts to copy — they're calibration for what good looks like):**

When the outfit works:
- *"Quiet confidence — the kind people remember without knowing why."*
- *"This is doing the work. You can leave."*
- *"Three textures, one mood. That's the trick."*

When the outfit needs a tweak:
- *"Almost there — one more anchoring piece and this lands."*
- *"The colors are good friends. The shapes are still working it out."*

When the outfit isn't strong:
- *"Brave choice. Possibly too brave. Want a second opinion?"*
- *"I have notes. Mostly affectionate."*

When the AI is uncertain:
- *"I'm 50/50 on this one — the silhouette works but the proportions are tricky."*

**Loading screen phrases** (cycle through these during "Thinking..."):
- *"looking closely…"*
- *"reading the outfit…"*
- *"thinking it over…"*
- *"checking the proportions…"*
- *"finding the right words…"*

**Error and edge case copy:**

No outfit visible:
- *"I can't quite see the outfit — want to try another angle?"*

Low light:
- *"Hard to read in this light, but here's what I caught."*

Network failure mid-call:
- *"Lost the connection for a sec. Pull down to try again."*

Rate limit hit:
- *"You've had a lot of vibe-checks today. Try again tomorrow."*

Zero garments extracted on first photo (already in Step 2.7):
- *"This one was a little tricky to read — want to try another photo? Sometimes a different angle or better light makes all the difference."*

---

# Pre-launch security checklist

Before submitting to TestFlight:

- [ ] Firestore Security Rules cover every collection with default-deny, unit-tested against the emulator
- [ ] Storage Security Rules cover every path with default-deny
- [ ] App Check enforced on Firestore, Storage, AND Firebase AI Logic (all three)
- [ ] Replay-attack protection enabled on App Check tokens
- [ ] Per-user daily Gemini rate limit verified
- [ ] Cloud Billing hard cap set on the Firebase project
- [ ] All Cloud Functions verify `context.auth.uid` and resource ownership
- [ ] No secrets in code or in the iOS app binary (Skimlinks/Awin keys not in MVP, but verify nothing is sneaking in)
- [ ] Structured outputs (`responseSchema`) used for all Gemini calls
- [ ] No photo bytes, no `gs://` URIs, no prompt content with user data logged in Cloud Logging
- [ ] Crashlytics symbolication doesn't expose photo data
- [ ] A red-team pass: someone tries to extract the `.ipa` and abuse the endpoints

---

# Decisions resolved (for the agent's reference)

All six original `[DECISION POINT]` items have been answered. Here's the summary:

1. **Firestore region**: `eur3` (EU multi-region, Frankfurt + Netherlands). Multi-region expansion is post-MVP.
2. **Style vector axes**: deferred. Start with a placeholder set of 5 (`vibe`, `formality`, `colorfulness`, `cohesion`, `statement_strength`). Gemini scores each from the photo. **The agent should pause and ask the human for the final axis list when the time comes** — typically after a few weeks of prototype testing, when the human signals readiness.
3. **Taste calibration cards**: deferred. The whole taste calibration screen (Step 2.3) is skipped in MVP because it depends on the final axis list from item 2.
4. **Cropping for wardrobe items**: removed entirely. Wardrobe items reference the source photo, no per-garment crops. Avoids the computational cost and the crop-quality risk.
5. **Rate limiting**: Callable Cloud Function with limits read from Remote Config. Default `daily_vibe_check_limit = 1000` during development (effectively unlimited). Numbers tighten near launch. This boundary is also the future subscription-offer hook.
6. **Zero-extraction handling**: polling Option A. **For the first vibe-check specifically**, if extraction returns zero garments, invite a retry with a friendly card — no caps on retry attempts during onboarding.

The one **new decision still pending** (not from the original list) is when the human will signal that the style axes are ready to be locked in. That triggers the un-deferring of Step 2.3 (taste calibration) and the refinement of Step 1.7's prompt.

