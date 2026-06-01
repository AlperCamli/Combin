# Combin — Tier 1 (SwiftUI)

A native iOS implementation of the **Combin** design handoff (`Combin-handoff.zip` →
`combin/project/Combin Tier 1.html`). Combin gives a warm, fast, fashion-literate
read on the outfit you're wearing — a one-line "vibe-check," the way a stylish
friend would text back.

This build covers **Tier 1**: Journey 1 (Onboarding) and Journey 2 (Daily mirror
check), on top of a **reusable design-system foundation** so Journeys 3–6 are
quick to add next.

## Run it

Open `Combin.xcodeproj` in Xcode 15+ and run on an iPhone simulator or device
(portrait, iOS 17+). The shared **Combin** scheme is already set up.

> **Note for this machine only:** the Swift code compiles, links, and bundles
> cleanly (verified with `xcodebuild`). If `xcodebuild` reports a
> `CompileAssetCatalog` failure with *"Failed to locate any simulator runtime,"*
> that's because no iOS simulator runtime is installed here — `actool` needs one
> to render the asset catalog. Installing any iOS runtime (Xcode ▸ Settings ▸
> Platforms, or `xcodebuild -downloadPlatform iOS`) resolves it. Nothing in the
> project needs changing.

## What's implemented

**Journey 1 — Onboarding** (`Screens/OnboardingScreens.swift`)
1. Welcome · 2. Trust & privacy · 3. Taste calibration (multi-select) ·
4. Permissions · 5. First photo capture · 6. First vibe-check result.

**Journey 2 — Daily mirror check** (`Screens/DailyScreens.swift`)
7. Camera default · 7b. Confirm context · 8. Looking… · 9. Vibe-check result ·
10. Expanded "tell me more."

The flows are **wired** (`Screens/AppFlow.swift`): onboarding runs once
(persisted in `UserDefaults`), then the app is camera-first — capture →
confirm → looking → result → expanded. The other four tabs (Discover, Education,
Planner, Wardrobe) are on-brand placeholders that exercise the reusable `TabBar`;
their full journeys are next round.

## Design-system foundation (`DesignSystem/`)

- **`DesignTokens.swift`** — the warm-paper palette. The prototype authors color
  in **OKLCH**; SwiftUI has no OKLCH initializer, so `Color(oklch:_:_:)` converts
  OKLCH → sRGB at runtime and the original L/C/H values stay inline, matching the
  source one-to-one. Also the 2 / 4 / 14 px radius scale.
- **`Typography.swift`** — Newsreader (serif), Geist (sans), Geist Mono (markers),
  with CSS-style `lineHeight`/`tracking` helpers.
- **`Icons.swift`** — `Sym`, mapping the prototype's icon names to **real SF
  Symbols** (the brief's non-negotiable #7), with stroke→weight matching.
- **`Components.swift`** — the striped `Photo` placeholder (diagonal two-tone
  stripes + mono label), the considered `Btn` (flat, low-radius), the custom
  five-item `TabBar` with its raised terracotta capture button, and the camera
  `FrameGuide`.

## Translation decisions

These are deliberate choices to recreate the **visual output** in the right
native technology, rather than copy the prototype's web scaffolding:

- **No fake device frame.** The HTML draws its own rounded corners, dynamic
  island, status bar, and home indicator because it's a mockup in an artboard.
  On a real device the system provides all of that, so screens fill the real safe
  area and set the status-bar style per screen (`preferredColorScheme`).
- **SF Symbols** instead of the prototype's hand-drawn "SF-Symbol-like" SVGs —
  the brief explicitly calls for SF Symbols with aligned line weight.
- **Real fonts bundled.** Newsreader, Geist, and Geist Mono ship in
  `Resources/Fonts/` (declared in `Info.plist` `UIAppFonts`, plus a launch-time
  CoreText registration as a fallback).
- **Striped photo placeholders are kept** — the design intentionally never fakes
  editorial photography; every image is a labelled placeholder until real
  photography is commissioned.

Honored throughout: no score/stars/percentages, no sparkle-near-AI, no gradients
on UI, the vibe-check one-liner treated as a pull quote, "Looking…" as a moment
(a soft shimmer) rather than a spinner.

## Layout

```
Combin.xcodeproj
Combin/
  CombinApp.swift            @main, font registration
  Info.plist                 portrait, UIAppFonts, usage strings
  DesignSystem/              tokens, typography, icons, components
  Screens/                   onboarding, daily, app flow + tab shell
  Resources/Fonts/           Newsreader · Geist · Geist Mono (.ttf)
  Assets.xcassets/           AppIcon (placeholder) · AccentColor (terracotta)
```
