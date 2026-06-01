# CLAUDE.md

**Combin** is a native iOS app (SwiftUI, iOS 17+, portrait) that gives a warm,
one-line "vibe-check" on the outfit you're wearing — the way a fashion-literate
friend would text back. It's built from a Claude Design handoff in
`Combin-handoff/` (read [Combin Tier 1.html](Combin-handoff/combin/project/Combin%20Tier%201.html)
and its `.jsx` imports for the source designs).

**Current state:** Tier 1 is implemented — Journey 1 (onboarding) + Journey 2
(daily mirror check), on a reusable design system. Journeys 3–6 are next.
Full status and the step-by-step plan live in [docs/handoff.md](docs/handoff.md).

**Layout:** `Combin/DesignSystem/` (tokens, typography, icons, components),
`Combin/Screens/` (screens + `AppFlow.swift` navigation). Open `Combin.xcodeproj`.

**Conventions / non-negotiables (from the brief):** quiet, editorial, restrained.
Two typefaces (Newsreader serif + Geist), one terracotta accent, OKLCH colors via
`Color(oklch:)`, low-radius shapes. SF Symbols only. **Never:** scores/stars/%,
sparkle-near-AI, UI gradients, prices in Discover/Education. The vibe-check
one-liner is the hero — treat it like a pull quote.
