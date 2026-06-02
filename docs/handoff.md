# Combin — Implementation Handoff

Status as of **2026-06-02**. Native iOS app (SwiftUI) built from the Claude Design
handoff (`Combin-handoff.zip` → [Combin Tier 1.html](../Combin-handoff/combin/project/Combin%20Tier%201.html)). The zip is unpacked into the project folder.

See [README.md](../README.md) for run instructions. This doc records **what's
implemented** and the **plan for the next steps**.

---

## 1. What's done

### Design-system foundation ([Combin/DesignSystem/](../Combin/DesignSystem/))
- [DesignTokens.swift](../Combin/DesignSystem/DesignTokens.swift) — warm-paper
  palette. Colors are authored in **OKLCH** in the prototype; `Color(oklch:_:_:)`
  converts OKLCH → sRGB at runtime so values match the source one-to-one. Includes
  the 2 / 4 / 14 px radius scale (`R`).
- [Typography.swift](../Combin/DesignSystem/Typography.swift) — Newsreader (serif),
  Geist (sans), Geist Mono (markers); `.serif/.sans/.mono` `Text` helpers with
  CSS-style `lineHeight`/`tracking`; `MonoMarker` for the uppercase labels.
- [Icons.swift](../Combin/DesignSystem/Icons.swift) — `Sym`, mapping every
  prototype icon name to a real **SF Symbol** (brief non-negotiable #7), with
  stroke→font-weight matching. All 38 names verified to resolve.
- [Components.swift](../Combin/DesignSystem/Components.swift) — striped `Photo`
  placeholder (7 tones × light/dark), the considered `Btn`, the custom five-item
  `TabBar` with the raised terracotta capture button, the camera `FrameGuide`,
  plus the shared `Chip`, `SegmentedToggle`, `PageDots`, and `FlowLayout`.

### All six journeys — shipped

**Journey 1 — Onboarding** ([OnboardingScreens.swift](../Combin/Screens/OnboardingScreens.swift))
Welcome · Trust & privacy · Taste calibration (multi-select) · Permissions ·
First photo capture · First vibe-check result.

**Journey 2 — Daily mirror check** ([DailyScreens.swift](../Combin/Screens/DailyScreens.swift))
Camera default · Confirm context · "Looking…" (soft shimmer, not a spinner) ·
Vibe-check result + tweak card · Expanded "tell me more."

**Journey 3 — Outfit planner** ([PlannerScreens.swift](../Combin/Screens/PlannerScreens.swift))
Plan entry · Context (chips + auto-weather) · Suggestions carousel (with "YOURS"
badges + page dots) · Suggestion detail · Suggested-items shop surface — the only
screen with prices, walled off from the AI layer.

**Journey 4 — Wardrobe** ([WardrobeScreens.swift](../Combin/Screens/WardrobeScreens.swift))
Looks grid + Items mode (segmented toggle) · Item detail (attributes + inline
Edit) · Inline contextual correction (sheet over a dimmed screen).

**Journey 5 — Discover** ([DiscoverScreens.swift](../Combin/Screens/DiscoverScreens.swift))
Discover home (hero + brand rail + movements) · Brand page · Item detail (no
price) · Where to find (retailer click-out sheet). No prices anywhere.

**Journey 6 — Education** ([EducationScreens.swift](../Combin/Screens/EducationScreens.swift))
Education home (Daily Insight + Daily Puzzle card) · Daily Insight reader
(drop-cap) · Daily Puzzle play (accent empty slot) · Daily Puzzle response
(direction-language, never "wrong"). No commerce.

### Navigation / shell ([AppFlow.swift](../Combin/Screens/AppFlow.swift))
`AppState` persists onboarding completion in `UserDefaults`. Camera-first model:
onboarding runs once → `MainShell` presents the camera flow over the tab world.
Camera flow is a state machine: camera → confirm → looking → result → expanded
(expanded rises as a bottom sheet over the result). Each non-camera tab is its
own self-contained journey flow that embeds the reusable `TabBar` on its root
screen and drives its own internal navigation (details push in; shop / where-to-
find / correction rise as bottom sheets).

### Project / config
- Hand-written classic `objectVersion = 56` [project.pbxproj](../Combin.xcodeproj/project.pbxproj)
  (Xcode 15 compatible) + shared **Combin** scheme.
- [Info.plist](../Combin/Info.plist) — portrait, `UIAppFonts`, usage strings.
- Real fonts bundled in [Resources/Fonts/](../Combin/Resources/Fonts/); asset
  catalog with placeholder `AppIcon` and terracotta `AccentColor`.

**Verified:** `xcodebuild` reaches `** BUILD SUCCEEDED **` (all six journeys
compile + link, no warnings, fonts bundled).
Caveat: this machine has **no iOS simulator runtime**, so `actool` fails the
`CompileAssetCatalog` step locally — environment-only, resolved by installing any
iOS runtime. (Details in README.)

### Translation decisions
- **No fake device frame** — the HTML's drawn status bar / dynamic island / home
  indicator are artboard chrome; screens fill the real safe area and set
  status-bar style via `preferredColorScheme`.
- **SF Symbols** instead of the prototype's hand-drawn SVGs.
- **Striped photo placeholders kept** — the design never fakes editorial photos.

---

## 2. Next steps — implementation plan

All 26 designed screens are now implemented. What remains is Tier-3 work (brief
§7, §9, §10) and the cross-cutting polish that turns the static recreation into a
living product.

### Round 3 — Tier 3 (brief §7, §9, §10)
- **Settings / privacy controls** and the consistent **"your data" affordance**
  (lock/shield → sheet: what's here, who sees it, how to delete). Spec'd once,
  reused under photos, in the result corner, in the camera viewport, in settings.
- **Empty / error / edge states as first-class** (brief §9): outfit-not-visible,
  bad-lighting caveat, **offline queue** ("I'll have thoughts when you're back
  online"), empty wardrobe, permissions-denied fallback, low-confidence read.
  All in the same warm voice.

### Cross-cutting (the static screens → a real app)
- **Real capture** — swap the striped `Photo` viewport for an `AVFoundation`
  camera preview + `PhotosPicker` for "use a recent one"; thread the captured
  image through confirm → looking → result.
- **AI integration** — replace the hard-coded vibe-check / planner / puzzle copy
  with real calls. Honor the interaction-notes timing: hold "Looking…" ≥1.2s even
  if the API is faster; switch to "Still looking — almost there." after 3s; warm
  fallback on failure. See [spec-sheets.jsx](../Combin-handoff/combin/project/spec-sheets.jsx)
  `InteractionNotes`.
- **Real data model** — wardrobe items, looks, saved planner outfits, puzzle
  state (persisted); replace the hard-coded arrays in each journey.
- **Click-out** — wire Discover "Where to find" and the planner shop surface to
  `SFSafariViewController` / `openURL` with real retailer links.
- **Motion fidelity** — capture-button press (compress 4%), frozen-frame
  scale 1.00→0.98, sheet snap (not bounce), one-liner fade-up 8px @420ms, tweak
  card +600–800ms. (`VibeCheckGuide` + `InteractionNotes`.)
- **Accessibility** — Dynamic Type (scale the type ramp), VoiceOver labels for
  `Sym`/`Photo`/controls, verify down to iPhone SE (375×667). Several fixed-height
  screens already moved to `ScrollView`; audit the rest under large type.
- **Dark "warm-dim" pass** — the `d*` tokens exist; audit the light-only journeys
  that should also support warm-dim dark mode (vs. the inherently-dark camera).
- **Haptics** — soft on capture and on save; **none** on result delivery.

### Known shortcuts to revisit
- Tab flows reset their internal navigation state when you switch tabs (each flow
  is recreated). Fine for now; revisit if tab state should persist.
- Detail back-navigation in Discover uses a simple `itemFromBrand` flag rather
  than a real navigation stack.
- The inline-correction / where-to-find "dimmed screen behind the sheet" is drawn
  per-screen rather than presenting over the live parent.

---

## 3. Open questions to confirm (from the brief §13)
- "headed where?" context pill — keep, or drop as dead weight? (Currently present,
  low-contrast, opens the confirm sheet.)
- Vibe-check result as **full-screen** (current) vs **bottom sheet** — worth
  prototyping the sheet variant.
- Wardrobe entry — **corner glyph** (current) vs a fourth tab.
