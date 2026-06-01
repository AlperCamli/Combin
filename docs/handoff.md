# Combin — Implementation Handoff

Status as of **2026-06-02**. Native iOS app (SwiftUI) built from the Claude Design
handoff (`Combin-handoff.zip` → [Combin Tier 1.html](../Combin-handoff/combin/project/Combin%20Tier%201.html)). The zip is unpacked into the project folder.

See [README.md](../README.md) for run instructions. This doc records **what's
implemented** and the **plan for the next steps**.

---

## 1. What's done

### Tier 1 — shipped

**Design-system foundation** ([Combin/DesignSystem/](../Combin/DesignSystem/))
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
  placeholder (diagonal two-tone stripes + mono label, all 7 tones × light/dark),
  the considered `Btn` (flat, low-radius), the custom five-item `TabBar` with the
  raised terracotta capture button, the camera `FrameGuide`, and the `Overlay`
  colors / `hairline` helper.

**Journey 1 — Onboarding** ([Screens/OnboardingScreens.swift](../Combin/Screens/OnboardingScreens.swift))
Welcome · Trust & privacy · Taste calibration (interactive multi-select) ·
Permissions · First photo capture · First vibe-check result.

**Journey 2 — Daily mirror check** ([Screens/DailyScreens.swift](../Combin/Screens/DailyScreens.swift))
Camera default · Confirm context (interactive occasion + weather) · "Looking…"
(soft shimmer, not a spinner) · Vibe-check result + tweak card · Expanded
"tell me more."

**Navigation / shell** ([Screens/AppFlow.swift](../Combin/Screens/AppFlow.swift))
`AppState` persists onboarding completion in `UserDefaults`. Camera-first model:
onboarding runs once → `MainShell` presents the camera flow over a tab world.
Camera flow is a state machine: camera → confirm → looking → result → expanded
(expanded rises as a bottom sheet over the result). The four non-camera tabs are
on-brand placeholders driving the reusable `TabBar`.

**Project / config**
- Hand-written classic `objectVersion = 56` [project.pbxproj](../Combin.xcodeproj/project.pbxproj)
  (Xcode 15 compatible) + shared **Combin** scheme.
- [Info.plist](../Combin/Info.plist) — portrait, `UIAppFonts`, usage strings.
- Real fonts bundled in [Resources/Fonts/](../Combin/Resources/Fonts/); asset
  catalog with placeholder `AppIcon` and terracotta `AccentColor`.

**Verified:** `xcodebuild` reaches `** BUILD SUCCEEDED **` (Swift compiles +
links, Info.plist processed, all 3 fonts bundled).
Caveat: this machine has **no iOS simulator runtime**, so `actool` fails the
`CompileAssetCatalog` step locally — environment-only, resolved by installing any
iOS runtime. (Details in README.)

### Translation decisions already made
- **No fake device frame** — the HTML's drawn status bar / dynamic island / home
  indicator are artboard chrome; screens fill the real safe area and set
  status-bar style via `preferredColorScheme`.
- **SF Symbols** instead of the prototype's hand-drawn SVGs.
- **Striped photo placeholders kept** — the design never fakes editorial photos.

---

## 2. Next steps — implementation plan

All remaining screens already exist in the handoff `.jsx` and reuse the design
system above. Order follows the brief's tiers.

### Round 2a — Journey 3: Outfit planner
Source: [screens-planner.jsx](../Combin-handoff/combin/project/screens-planner.jsx) →
new `Combin/Screens/PlannerScreens.swift`.

| Screen | Notes |
|---|---|
| `S_PlanEntry` | First-visit framing + "quick start" 2-col photo cards + `Btn`. Reuses `TabBar(active:"planner")`. |
| `S_Context` | **New component: `Chip`** (selectable pill, 2px radius). Occasion / vibe chip rows, auto-weather card, dress-code text field. |
| `S_Suggestions` | Carousel "look 1 of 3": one-liner + composed `Photo` + horizontal garment thumbnails with a **"YOURS" badge overlay** + dot page indicator. |
| `S_SuggestionDetail` | "from your closet" list rows + a descriptive "piece you don't have" card with an **opt-in Shop suggestions** disclosure. |
| `S_ShopSurface` | **The only screen with prices.** Affiliate-disclosure note + retailer cards ("View on …" click-out). Keep walled off from AI feedback. |

New pieces: `Chip`, a reusable horizontal carousel + `PageDots`, the garment-thumb
"YOURS" badge, the shop/retailer row.

### Round 2b — Journey 4: Wardrobe
Source: [screens-wardrobe.jsx](../Combin-handoff/combin/project/screens-wardrobe.jsx) →
`Combin/Screens/WardrobeScreens.swift`. **Replaces the Wardrobe placeholder.**

| Screen | Notes |
|---|---|
| `S_WardrobeGrid` | Default landing. **New: Looks/Items segmented toggle** (custom on-brand pill). 3-col `Photo` grid; first cell "just now" badge, later cells faded; inline first-visit framing top + bottom. |
| `S_WardrobeItems` | Items mode — categorized garment sections (tops/outerwear/bottoms/shoes) with counts, 4-col grids. |
| `S_ItemDetail` | Extracted-source photo, "what i see" attribute rows with inline **Edit** (accent), "worn in N looks" thumb row, destructive actions (`Mark as donated` / `Hide`). |
| `S_InlineCorrect` | **Bottom-sheet over a dimmed screen** — correction options list with check states + `Btn`. Generalize the sheet presentation from the camera flow. |

New pieces: `SegmentedToggle`, attribute/list rows, a reusable dimmed-backdrop
bottom-sheet container.

### Round 2c — Journey 5: Discover
Source: [screens-discover.jsx](../Combin-handoff/combin/project/screens-discover.jsx) →
`Combin/Screens/DiscoverScreens.swift`. **No prices anywhere.**

| Screen | Notes |
|---|---|
| `S_DiscoverHome` | Hero card with overlaid title, "brands in rotation" horizontal rail, "movements & references" 2-col grid. Reuses `TabBar(active:"discover")`. |
| `S_BrandPage` | Large serif brand name, editorial paragraph, accent "Learn about …" link, S/S items grid. |
| `S_ItemDetailDisco` | Tall photo, description, **"Where to find" card (no price)**, "read more" link. |
| `S_WhereToFind` | Bottom sheet — retailer list rows (name + domain + click-out arrow) + "you'll leave Combin" disclosure. |

### Round 2d — Journey 6: Education
Source: [screens-education.jsx](../Combin-handoff/combin/project/screens-education.jsx) →
`Combin/Screens/EducationScreens.swift`. **No commerce, ever.**

| Screen | Notes |
|---|---|
| `S_EduHome` | "today" Daily Insight hero + **Daily Puzzle card** (mini outfit row with an accent empty slot + Play). "this week" curated feed rows. Reuses `TabBar(active:"edu")`. |
| `S_DailyInsight` | Editorial reader — **new: drop-cap** first paragraph, generous serif body. |
| `S_PuzzlePlay` | "the condition" + base outfit 2-col grid with one accent **empty slot tile**; search-the-closet affordance. |
| `S_PuzzleResponse` | "you picked" + **direction-language** response (never "wrong") + "three that would have worked" horizontal cards. |

New pieces: drop-cap paragraph, puzzle slot tile, the puzzle card for the home.

### Round 3 — Tier 3 (brief §7, §9, §10)
- **Settings / privacy controls** and the consistent **"your data" affordance**
  (lock/shield → sheet: what's here, who sees it, how to delete). Spec'd once,
  reused under photos, in the result corner, in the camera viewport, in settings.
- **Empty / error / edge states as first-class** (brief §9): outfit-not-visible,
  bad lighting caveat, **offline queue** ("I'll have thoughts when you're back
  online"), empty wardrobe, permissions-denied fallback, low-confidence read.
  All in the same warm voice.

### Cross-cutting polish (do alongside, not last)
- **Real capture** — swap the striped `Photo` viewport for `AVFoundation` camera
  preview + `PhotosPicker` for "use a recent one"; thread the captured image
  through confirm → looking → result.
- **AI integration** — replace the hard-coded vibe-check copy with a real call;
  honor the interaction-notes timing (hold "Looking…" ≥1.2s even if the API is
  faster; switch to "Still looking — almost there." after 3s; warm fallback on
  failure). See [spec-sheets.jsx](../Combin-handoff/combin/project/spec-sheets.jsx)
  `InteractionNotes`.
- **Motion fidelity** — capture-button press (compress 4%), frozen-frame
  scale 1.00→0.98, sheet snap (not bounce), one-liner fade-up 8px @420ms, tweak
  card +600–800ms. (`VibeCheckGuide` + `InteractionNotes` in spec-sheets.)
- **Accessibility** — Dynamic Type (scale the type ramp), VoiceOver labels for
  `Sym`/`Photo`/controls, and verify down to iPhone SE (375×667). Several Tier-1
  fixed-height screens should move to `ScrollView` to stay safe under large type.
- **Dark "warm-dim" pass** — the `d*` tokens exist; audit light-only screens that
  should respect a warm-dim dark mode (vs. the inherently-dark camera screens).
- **Haptics** — soft on capture and on save; **none** on result delivery.

### Suggested sequencing
1. Wardrobe (Journey 4) first — it's the onboarding handoff destination
   ("Show me my closet") and currently a placeholder.
2. Then Planner, Discover, Education (independent; any order).
3. Fold in the "your data" affordance + empty/error states as each journey lands.
4. Real camera + AI + motion polish once the static journeys are complete.

---

## 3. Open questions to confirm (from the brief §13)
- "headed where?" context pill — keep, or drop as dead weight? (Currently present,
  low-contrast, opens the confirm sheet.)
- Vibe-check result as **full-screen** (current) vs **bottom sheet** — worth
  prototyping the sheet variant.
- Wardrobe entry — **corner glyph** (current) vs a fourth tab.
