# Combin — Claude Design Brief

**Purpose:** Turn the locked product journeys into iOS UI prototypes.
**Date:** 2026-05-07
**Companion document:** `combin-user-journeys-v2.md` (treat this brief as the *visual translation layer* for that doc).
**Priority for first round:** Journey 1 (Onboarding) and Journey 2 (Daily Mirror Check). Everything else can come second.

---

## 1. What Combin is, in one paragraph

Combin is an iOS app that gives a user a warm, fast, fashion-literate read on the outfit they're wearing right now. The user takes a mirror selfie or uploads a photo; the app responds with a one-line "vibe-check" — the way a stylish friend would text back. Over time the app builds a passive wardrobe memory and starts surfacing personalized tweaks ("try the olive jacket from two weeks ago"). It also has a Discover tab (a no-prices fashion catalog) and an Education tab (Daily Insight + Daily Puzzle + deep-dives). The app is opinionated, editorially weighty, and deliberately not a shopping app.

---

## 2. The single most important thing to understand

**This app does not look or feel like other AI apps.** No score cards. No "AI Analysis Complete" headers. No three-bullet feedback lists. No purple-blue gradients. No sparkle icons. No "✨ Powered by AI ✨".

The user is supposed to feel like they're reading a text from a friend who knows clothes. Everything visual — typography, spacing, motion, color, copy — should serve that feeling. If a design choice would feel at home in a productivity SaaS or a generic AI tool, it's wrong for Combin.

The reference points are closer to: a well-designed fashion magazine app (Vestoj, SSENSE editorial), a thoughtful reading app (Reeder, Matter), a high-end product app (Aesop, Maison Margiela). Not Lensa, not Notion AI, not ChatGPT.

---

## 3. Non-negotiables (do not override these)

These are locked product decisions. Don't propose alternatives.

1. **No score, ever.** No 7/10, no stars, no thumbs, no "Confidence: 85%". The vibe-check is prose, full stop.
2. **The vibe-check one-liner is the app's hero element.** It deserves typographic treatment as a system primitive — the way a magazine treats a pull quote.
3. **No commerce in the AI feedback layer or in Education.** Zero. The mirror moment is sacred.
4. **No prices in Discover.** Click-out to retailers exists, but prices appear *after* the user leaves the app.
5. **Two non-camera tabs:** Discover and Education. Plus a wardrobe view accessible from the camera screen. The default state of the app is *camera open*, not a home feed.
6. **Body & identity neutrality is a system requirement.** Every illustration, mannequin, onboarding example, and empty state represents a real range of bodies, skin tones, gender presentations, ages. Not a diversity pass at the end — designed in from the first wireframe.
7. **iOS-native feel.** SF Symbols, native sheets and haptics, Dynamic Type, VoiceOver-friendly.

---

## 4. Aesthetic direction

### Tone of the visuals

Quiet, confident, considered. The app should feel like it was art-directed, not assembled. White space is a feature. Restraint is the brand.

If the screen looks "designed," it's wrong. If it looks "edited," it's right.

### Color

A **neutral, paper-toned palette** as the base. Off-white / warm-grey backgrounds (closer to magazine paper than to iOS system white). One restrained accent color used sparingly — for the active state of the capture button, for the Daily Puzzle progress, for one or two purposeful moments per screen. No gradients. No "AI shimmer" colors (purples, electric blues, neon greens). Deep blacks for text, never pure #000.

Dark mode should feel like a different *room*, not a color-inverted version of light mode. Think: warm dim, not cold dark.

### Typography

Two-typeface system at most. A serif for editorial moments — the vibe-check one-liner, the Daily Insight headline, brand notes in Discover. A clean sans-serif for UI, microcopy, and longer body text. The serif is the brand voice; treat it with care.

The vibe-check one-liner specifically should feel like a magazine pull quote: large, generous leading, sit in space, breathe.

### Photography

Photos in the app are the user's own outfit photos and curated catalog imagery. The UI should *frame* photography, never compete with it. Image containers should have consistent corner radius (a low-radius, considered shape — not the iOS-default 12px friendly-pill look). Drop shadows: minimal, almost-imperceptible if used at all.

### Motion

Slow, intentional, soft. Bottom sheets snap; they don't bounce. Loading is a moment, not a spinner. Page transitions are crossfades or subtle slides, not whooshes. Haptics: yes on capture, yes on Puzzle unlock, no on result delivery (feels like a slot machine reward).

### Iconography

SF Symbols, line weight aligned. No custom flat-design icon set. No emoji in UI chrome.

---

## 5. The visual treatment of the vibe-check (most leveraged design moment)

The vibe-check one-liner is the signature of the entire product. It deserves more design thought than any other element. Specifically:

- **It should sit alone on the screen** the moment it appears. No surrounding chrome. No buttons crowding it. Just the line, in the serif, with breath around it.
- **It enters with motion** — subtly. A short fade-up, maybe a few hundred ms. The line *arrives*, it doesn't pop.
- **The optional tweak card appears below it after a beat** — separately, not as part of the same composition. The reader finishes the one-liner first, then notices there's more.
- **The tweak card is visually quieter** than the one-liner — smaller type, the supporting voice.
- **Action chrome (save, share, "tell me more") is at the bottom edge, low-contrast** — present but not pulling focus.

If the vibe-check feels like a notification banner or a chat bubble, the design has failed. It should feel like reading something printed.

---

## 6. Tone of voice (this affects every microcopy decision)

The voice is **a fashion-literate friend who texted back fast**. Specific. Warm. Confident. Funny when humor lands. Never preachy, never schoolmarmish, never AI-assistant flat.

**Words to avoid throughout the UI:**
- "Wrong," "incorrect," "bad," "mistake," "error," "fail" → use direction-language ("this pushes the outfit toward casual")
- "Should," "must," "need to" → use "try," "consider," "what about"
- "Beautiful," "stunning," "gorgeous" → use specific observations
- "Analyzing your outfit," "AI is thinking," "Processing" → use "Looking..." or "One sec..."

**Examples of the voice in vibe-check copy:**

When the outfit works:
- "Quiet confidence — the kind people remember without knowing why."
- "Three textures, one mood. That's the trick."

When it needs a tweak:
- "Almost there — one more anchoring piece and this lands."

When it doesn't work (humor as kindness):
- "Brave choice. Possibly too brave. Want a second opinion?"
- "I have notes. Mostly affectionate."

When uncertain:
- "I'm 50/50 on this — the silhouette works but the proportions are tricky."

This voice carries through to every screen. Empty states, loading states, error states, settings, onboarding — same hand.

---

## 7. Priority screens for round 1

Build these first, in this order:

### Tier 1 — must have for round 1
1. **Welcome / first-launch screen** (Journey 1, step 1)
2. **Trust & privacy screen** (Journey 1, step 2)
3. **Taste calibration grid** (Journey 1, step 3)
4. **Permissions screen** (Journey 1, step 4)
5. **First photo capture** (Journey 1, step 5)
6. **First vibe-check result** (Journey 1, step 5)
7. **Camera default state** (Journey 2, step 1) — *the most-used screen in the app*
8. **Capture → thinking → result flow** (Journey 2, steps 2–4)
9. **Vibe-check result with optional tweak card** (Journey 2, step 4)
10. **Expanded "tell me more" read** (Journey 2, step 5)

### Tier 2 — round 2
11. Outfit planner: context capture + suggestions carousel
12. Wardrobe grid + item detail
13. Discover home + brand page + item detail
14. Education home + Daily Insight reader
15. Daily Puzzle full flow

### Tier 3 — round 3
16. Settings, privacy controls, "your data" affordance
17. All empty / error / failure states
18. Wardrobe correction flows

---

## 8. Per-screen specs (Tier 1)

For each screen, I'm giving the *constraints* that matter and leaving room for design to breathe inside them.

### 8.1 Welcome screen

**Job:** Communicate value in one sentence and earn the next tap.
**Layout:** Full-bleed background (a single, well-art-directed image — a real person, real clothing, not stock-photo-generic). One sentence in the serif, set large. One CTA. That's it.
**Microcopy:**
- Headline: "Your stylist in your pocket."
- Subhead: "Honest when you ask. Kind every time."
- CTA: "Let's go" (not "Get Started" — too SaaS)
**Don't:** Three swipeable intro slides. Feature lists. Logo lockups bigger than the headline.

### 8.2 Trust & privacy screen

**Job:** This screen carries more weight than any other in onboarding. If it feels legalistic, users bounce. If it feels confident and human, they trust the rest of the app.
**Layout:** Plain-language privacy summary in 4 short statements, each with a small icon (SF Symbol weight). Two CTAs: "Got it" (primary) and "Tell me more" (expands inline, doesn't navigate away).
**The four statements:**
- "Your photos stay on your device when possible."
- "What we send to the AI is encrypted."
- "Delete any photo, any time."
- "We never sell your data, and there are no ads."
**Don't:** A wall of text. A "By tapping Continue you agree to..." footer. Legal terms front and center.

### 8.3 Taste calibration grid

**Job:** Calibrate AI baseline AND signal to the user that they're being heard before being asked to give.
**Layout:** A grid of 8–10 outfit cards, multi-select tap. Cards span gender presentations, body types, formality levels, climate-appropriate looks. A small caption above: "Which feel like you?" Skip is allowed in the corner.
**Visual treatment:** Cards are photographic, considered, real. No illustrations of mannequins. The cards themselves are the brand statement here — if they feel generic, the app feels generic.
**Don't:** A questionnaire. Sliders ("How formal are you on a scale of 1–10"). Forcing the user to pick at least N.

### 8.4 Permissions screen

**Job:** Frame permissions as functional, not surveillance.
**Layout:** Two cards, location and notifications. Each card has a one-line *reason* in plain English, not "We need access to your location to provide weather-aware recommendations."
**Microcopy:**
- Location: "So we can factor in if it's freezing or pouring."
- Notifications: "A daily insight, when you want it. Off by default."
- Skip CTA: "Maybe later"
**Don't:** Stack permissions in a list. Use "tap Allow" instructions (the OS handles that).

### 8.5 First photo capture

**Job:** Communicate that mirror selfies, gallery uploads, and someone-else-taken photos all work. Capture the first photo.
**Layout:** Full-bleed camera viewport. Two equally-prominent path buttons: "Take a photo" and "Use a recent one." A small line of microcopy: "Mirror selfie, gallery, someone-else-taken — all good. The outfit just needs to be visible."
**Don't:** Make the camera button visually dominant in a way that hides the gallery option. Force a specific framing or pose.

### 8.6 First vibe-check result

**Job:** This is the moment that earns the second visit. Slightly extra-warm than the standard vibe-check.
**Layout:** Same as the standard vibe-check (see 8.9), but followed by *one* tiny educational note tied to the outfit — planting the seed that this app teaches as well as reads. After the user finishes, they land on the camera default state. No "Welcome to Combin!" banner.

### 8.7 Camera default state (the most-used screen in the app)

**Job:** Ready-to-shoot. Shortest possible path to the next vibe-check.
**Layout:**
- Full-bleed camera viewport, front camera by default.
- Single floating Capture button, bottom-center, large.
- A subtle frame guide that signals "outfit visible here" without enforcing a strict crop.
- Top-left: small "headed where?" pill (optional, taps to set context: work / casual / event / dinner / skip). Pill is *low-contrast* — present but not pushing.
- Top-right corner: small wardrobe icon.
- Bottom-left corner: small gallery icon (use a recent photo).
- Bottom edge: tab bar with three tabs — Camera (default), Discover, Education. Tabs use SF Symbol icons + label, low-contrast when not active.
- No nav bar at the top, no menu, no logo. Capture is the only obvious action.
**Don't:** A home feed. A "good morning" greeting. A streak counter. Any onboarding nudges after the first run.

### 8.8 Capture → thinking → result flow

**Job:** Hide AI latency behind a feeling of intentionality.
**Sequence:**
1. Tap capture. Subtle haptic. Photo freezes with a tiny scale-down animation (~150ms).
2. Bottom sheet rises. Inside the sheet: the word "Looking..." in the serif, with a *very* subtle shimmer. Not a spinner. Not a progress bar.
3. Within ~1.5s, the vibe-check one-liner fades up in place of "Looking...". This is the hero moment — see section 5.
4. Within ~3s, *if* there's a tweak, it appears below as a separate card with a soft entrance. If there's no tweak, the one-liner stands alone (this is correct and good).
**Don't:** A loading spinner. "AI is thinking..." copy. A progress bar. A multi-step "analyzing color... analyzing fit... analyzing..." reveal — that's productivity-app design, not editorial design.

### 8.9 Vibe-check result screen

**Job:** Deliver the read. Most users exit here. That's correct.
**Layout (top to bottom):**
- The user's photo, slightly inset, with generous margin around it. Not full-bleed — the photo is *contained*, like an editorial layout.
- Below the photo: the **vibe-check one-liner** in the serif, large, with breathing room. This is the hero. (See section 5 for the full treatment.)
- Below that, optionally, the tweak card. Smaller, in the sans, with a thumbnail of any referenced wardrobe item. Tap thumbnail → see the source photo.
- At the bottom edge: a low-contrast action row — save, share, "tell me more" (expands a deeper read).
**Don't:** Stack the photo and the one-liner without any visual hierarchy. Surround the one-liner with chrome. Put a "Generated by AI" disclaimer near the one-liner — kills the magic. Show retry buttons up front (live in a settings menu of the result, not as primary chrome).

### 8.10 Expanded "tell me more" read

**Job:** For deliberate users — a deeper read with reasoning, occasion fit, weather notes, optional micro-education.
**Layout:** A scrollable sheet that takes up most of the screen. Reads like an editorial piece — paragraphs, not bullet points. Plenty of vertical space. Wardrobe item references inline, with thumbnails.
**Don't:** A "Pros / Cons" structure. A scoring breakdown by axis ("Fit: ★★★★, Color: ★★★"). A list of "5 reasons this works." This is prose, not analysis.

---

## 9. Failure / empty / edge states (treat as first-class)

About 30% of the early experience is failure states. They need the same care as the happy path. Some specifics:

- **Outfit not visible in photo:** "I can't quite see the outfit — want to try another angle?" Not an error frame. Not a red icon. Same warm voice.
- **Bad lighting:** Vibe-check still works, with a soft caveat: "Hard to read in this light, but here's what I caught."
- **No internet:** The one-liner waits in a queue. "I'll have thoughts when you're back online." With a small, calm queue indicator.
- **Empty wardrobe:** Not "Your wardrobe is empty." Instead: "I'm still learning your closet. Take a few photos and I'll start spotting things you already own." Illustration is a real photo of a single hanger or folded shirt, not a cute empty-state cartoon.
- **Permissions denied:** Flow continues. The fallback (manual context, gallery upload) is treated as a first-class path, not a degraded one.
- **AI low-confidence read:** Honesty over false enthusiasm. "I'm 50/50 on this — the silhouette works but the proportions are tricky."

---

## 10. The "your data" privacy affordance

There's a small, consistent visual treatment that signals "you control this" wherever photos, location, or wardrobe data appear. Spec it once, use everywhere:

- A small SF Symbol (lock or shield, low-contrast)
- Tappable
- Opens a sheet with: what data is here, who can see it, how to delete it
- Always uses the same language and the same shape

This appears: under any photo in the wardrobe view, in the corner of the result screen, in the camera viewport (subtle), in account settings.

Trust is built through repeated small signals, not a single privacy screen.

---

## 11. What to avoid (the AI-design clichés that would kill this brand)

- **Sparkle / star / wand icons** anywhere near AI features. ✨ is banned.
- **Purple-to-blue gradients.** Any gradient.
- **"Powered by AI" badges.** Even as a humble disclosure.
- **Score cards, rating stars, percentage confidence indicators.**
- **Three-bullet feedback structures.** Lists feel like critique. Prose feels like a friend.
- **Animated progress bars during AI thinking.**
- **"Generated by Gemini / Claude / GPT" attribution in user-facing copy.**
- **Cute mascots, illustrated robots, friendly assistant avatars.** No personification of the AI.
- **iOS-default 12px corner radius pills used as primary CTAs.** Considered shapes only.
- **Skeuomorphic flourishes** (paper-tear textures, faux-leather backgrounds, etc.). Restraint, not theme.
- **Onboarding tooltip overlays** ("Tap here to take your first photo!"). The interface should be self-evident.
- **Streak counters, daily challenges, points, leaderboards.** Not this app.
- **"Share to Instagram" buttons baked into the result chrome.** Share exists, but it's quiet and one of several actions.

---

## 12. Output format requested from Claude Design

For round 1, please produce:

- **High-fidelity static screens** for the 10 Tier 1 screens.
- **Interaction notes** for the capture → thinking → result flow (since the timing matters as much as the visuals).
- **A typography & color spec sheet** — the system primitives, since they'll govern all later screens.
- **A vibe-check one-liner treatment guide** — sizing, leading, motion. Since it's the signature element it deserves its own spec.

Light/dark mode versions where applicable. iPhone 15 Pro frame (393×852pt) as the canonical size; designs should work down to iPhone SE (375×667pt) and respect Dynamic Type.

---

## 13. Open questions for design (worth flagging back)

- The **"headed where?" context pill** on the camera screen — is it actually used in practice, or dead weight? Worth prototyping both with and without to see how the screen feels.
- **Bottom sheet vs full-screen result** for the vibe-check — I've specified bottom sheet for Tier 1, but the full-screen treatment gives the one-liner more room to be the hero. Worth showing both.
- **Where does the wardrobe icon live?** Top-right corner of the camera screen, or as a fourth tab? Tab adds clarity, corner keeps the camera focused. I lean corner; show both.
- **The Daily Puzzle visual identity** (round 2) — does it sit inside the Education tab visually, or does it earn its own typographic treatment as the second signature element after the vibe-check? My instinct: the latter, but worth discussing.

---

## 14. Reference files in the project

When in doubt, the canonical sources are:
- `combin-user-journeys-v2.md` — the locked product journeys (this brief is the visual translation of that document)
- `2026-05-07_fashion-editorial_daily-puzzle-format.md` — the Daily Puzzle spec
- `2026-05-07_fashion-editorial_discover-tab-no-prices-decision.md` — the Discover tab rules
- `2026-05-07_business-growth_affiliate-program-shortlist-mvp.md` — the planner's "Suggested items" surface rules

The brief above honors all four. Where this brief and the source documents disagree, the source documents win — flag the conflict back rather than designing through it.

---

**End of brief.**
