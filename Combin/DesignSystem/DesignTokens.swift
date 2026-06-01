//  DesignTokens.swift
//  Combin
//
//  The Combin design system — ported faithfully from the design handoff
//  (combin/project/primitives.jsx). Colors in the prototype are authored in
//  OKLCH; SwiftUI has no OKLCH initializer, so we convert OKLCH → sRGB here and
//  keep the original L/C/H values inline so the palette stays readable and
//  matches the source one-to-one.

import SwiftUI
import CoreGraphics

// MARK: - OKLCH → sRGB

extension Color {
    /// Create a `Color` from OKLCH. `l` in 0…1, `c` chroma, `h` hue in degrees.
    init(oklch l: Double, _ c: Double, _ h: Double, alpha: Double = 1) {
        let (r, g, b) = OKLCH.toSRGB(l, c, h)
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

enum OKLCH {
    /// Convert OKLCH to gamma-encoded sRGB components (0…1), clamped to gamut.
    static func toSRGB(_ L: Double, _ C: Double, _ Hdeg: Double) -> (Double, Double, Double) {
        let h = Hdeg * .pi / 180
        let a = C * cos(h)
        let b = C * sin(h)

        // OKLab → LMS (cube of the linearised cone responses)
        let l_ = L + 0.3963377774 * a + 0.2158037573 * b
        let m_ = L - 0.1055613458 * a - 0.0638541728 * b
        let s_ = L - 0.0894841775 * a - 1.2914855480 * b
        let lc = l_ * l_ * l_
        let mc = m_ * m_ * m_
        let sc = s_ * s_ * s_

        // LMS → linear sRGB
        let r =  4.0767416621 * lc - 3.3077115913 * mc + 0.2309699292 * sc
        let g = -1.2684380046 * lc + 2.6097574011 * mc - 0.3413193965 * sc
        let bb = -0.0041960863 * lc - 0.7034186147 * mc + 1.7076147010 * sc

        return (gamma(r), gamma(g), gamma(bb))
    }

    private static func gamma(_ x: Double) -> Double {
        let v = x <= 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1 / 2.4) - 0.055
        return min(1, max(0, v))
    }
}

// MARK: - Palette

/// Combin color tokens. `C.*` are the light "warm paper" tokens; the `d`-prefixed
/// tokens are the warm-dim (dark) variants — "a different room, not an inversion."
enum C {
    // Light — warm paper
    static let paper       = Color(oklch: 0.965, 0.008, 70)   // base bg, off-white warm
    static let paperDeep   = Color(oklch: 0.945, 0.012, 70)   // sheet / card divider surface
    static let paperLine   = Color(oklch: 0.880, 0.012, 70)   // hairlines
    static let ink         = Color(oklch: 0.180, 0.012, 60)   // primary text — never #000
    static let inkSoft     = Color(oklch: 0.400, 0.010, 60)   // secondary text
    static let inkMute     = Color(oklch: 0.580, 0.008, 60)   // tertiary / chrome
    static let accent      = Color(oklch: 0.550, 0.120, 40)   // terracotta-ink — single accent
    static let accentSoft  = Color(oklch: 0.550, 0.120, 40, alpha: 0.10)

    // Warm-dim (dark)
    static let dpaper      = Color(oklch: 0.180, 0.010, 60)
    static let dpaperDeep  = Color(oklch: 0.220, 0.010, 60)
    static let dpaperLine  = Color(oklch: 0.320, 0.010, 60)
    static let dink        = Color(oklch: 0.940, 0.008, 70)
    static let dinkSoft    = Color(oklch: 0.740, 0.010, 60)
    static let dinkMute    = Color(oklch: 0.560, 0.008, 60)
    static let daccent     = Color(oklch: 0.680, 0.110, 40)
}

// MARK: - Radii

/// The considered, low-radius shape language. The capture button is the only
/// fully-round element in the system.
enum R {
    static let input: CGFloat = 2   // text fields, chips
    static let card: CGFloat  = 4   // photo containers, CTAs, internal sheet elements
    static let sheet: CGFloat = 14  // only the top edge of bottom sheets
}
