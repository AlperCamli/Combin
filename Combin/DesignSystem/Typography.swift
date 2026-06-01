//  Typography.swift
//  Combin
//
//  Two-typeface system: Newsreader (serif, the editorial voice), Geist (sans, UI
//  and body), Geist Mono (tiny markers only). The fonts ship in the bundle and
//  are declared in Info.plist (UIAppFonts); we also register them at launch as a
//  belt-and-suspenders. If a custom face is somehow unavailable, Font.custom
//  falls back to the system font so the app still runs.

import SwiftUI
import CoreText

enum F {
    static let serifName = "Newsreader"
    static let sansName  = "Geist"
    static let monoName  = "Geist Mono"

    static func serif(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.custom(serifName, size: size).weight(weight)
    }
    static func sans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.custom(sansName, size: size).weight(weight)
    }
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.custom(monoName, size: size).weight(weight)
    }

    /// Register the bundled fonts with CoreText. Safe to call more than once.
    static func registerBundledFonts() {
        for name in ["Newsreader", "Geist", "GeistMono"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

// MARK: - Text styling helpers

/// SwiftUI has no exact CSS `line-height` (multiple). `.lineSpacing` adds points
/// *between* lines on top of the font's natural leading, so we approximate the
/// prototype's multiples by deriving extra spacing from the font size.
private func extraLineSpacing(size: CGFloat, lineHeight: CGFloat) -> CGFloat {
    max(0, size * (lineHeight - 1.25))
}

extension Text {
    /// Editorial serif line — the brand voice. `lineHeight` is a CSS-style multiple.
    func serif(_ size: CGFloat,
               weight: Font.Weight = .regular,
               color: Color,
               tracking: CGFloat = 0,
               lineHeight: CGFloat = 1.2) -> some View {
        self.font(F.serif(size, weight))
            .tracking(tracking)
            .foregroundStyle(color)
            .lineSpacing(extraLineSpacing(size: size, lineHeight: lineHeight))
    }

    /// Geist sans — UI, microcopy, longer body.
    func sans(_ size: CGFloat,
              weight: Font.Weight = .regular,
              color: Color,
              tracking: CGFloat = 0,
              lineHeight: CGFloat = 1.2) -> some View {
        self.font(F.sans(size, weight))
            .tracking(tracking)
            .foregroundStyle(color)
            .lineSpacing(extraLineSpacing(size: size, lineHeight: lineHeight))
    }

    /// Geist Mono — uppercase section markers only, 9.5–11pt, wide tracking.
    func mono(_ size: CGFloat,
              weight: Font.Weight = .regular,
              color: Color,
              tracking: CGFloat = 1.2) -> some View {
        self.font(F.mono(size, weight))
            .tracking(tracking)
            .foregroundStyle(color)
    }
}

/// A mono marker — the small uppercase labels used throughout ("02 / 04",
/// "ONE TWEAK", "WEATHER · AUTO"). Uppercases its content per the spec.
struct MonoMarker: View {
    var text: String
    var size: CGFloat = 9.5
    var color: Color = C.inkMute
    var tracking: CGFloat = 1.3
    init(_ text: String, size: CGFloat = 9.5, color: Color = C.inkMute, tracking: CGFloat = 1.3) {
        self.text = text; self.size = size; self.color = color; self.tracking = tracking
    }
    var body: some View {
        Text(text.uppercased()).mono(size, color: color, tracking: tracking)
    }
}
