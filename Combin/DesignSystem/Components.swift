//  Components.swift
//  Combin
//
//  Shared building blocks ported from primitives.jsx: the striped Photo
//  placeholder, the considered Btn (flat, low-radius — not an iOS pill), and the
//  custom five-item TabBar with its raised terracotta capture button.

import SwiftUI

// MARK: - Overlay colors (text/scrims over photos)

enum Overlay {
    /// Warm white used for copy and guides over photography — rgba(255,251,244).
    static let paperWhite = Color(red: 255/255, green: 251/255, blue: 244/255)
    /// The warm near-black used for scrims and chrome over photos — rgb(20,16,12).
    static let inkShadow  = Color(red: 20/255, green: 16/255, blue: 12/255)
}

// MARK: - FrameGuide

/// Soft corner brackets over the camera viewport — signals "outfit visible here"
/// without enforcing a strict crop. Inset 20% top / 12% sides / 26% bottom.
struct FrameGuide: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let rect = CGRect(x: w * 0.12, y: h * 0.20,
                              width: w * 0.76, height: h * 0.54)
            let stroke = Overlay.paperWhite.opacity(0.65)
            let len: CGFloat = 22
            ZStack {
                bracket(.topLeading,     rect: rect, len: len, color: stroke)
                bracket(.topTrailing,    rect: rect, len: len, color: stroke)
                bracket(.bottomLeading,  rect: rect, len: len, color: stroke)
                bracket(.bottomTrailing, rect: rect, len: len, color: stroke)
            }
        }
        .allowsHitTesting(false)
    }

    private func bracket(_ corner: UnitPoint, rect: CGRect, len: CGFloat, color: Color) -> some View {
        Path { p in
            let x = (corner == .topLeading || corner == .bottomLeading) ? rect.minX : rect.maxX
            let y = (corner == .topLeading || corner == .topTrailing) ? rect.minY : rect.maxY
            let dx: CGFloat = (corner == .topLeading || corner == .bottomLeading) ? len : -len
            let dy: CGFloat = (corner == .topLeading || corner == .topTrailing) ? len : -len
            p.move(to: CGPoint(x: x + dx, y: y))
            p.addLine(to: CGPoint(x: x, y: y))
            p.addLine(to: CGPoint(x: x, y: y + dy))
        }
        .stroke(color, lineWidth: 1)
    }
}

// MARK: - Photo (striped placeholder)

/// "Every photo is a striped placeholder — not a fake editorial shot."
/// A diagonal two-tone stripe fill with a small monospace explainer label.
enum PhotoTone {
    case neutral, warm, cool, olive, rust, char, ecru

    func pair(dark: Bool) -> (Color, Color) {
        switch self {
        case .neutral:
            return (Color(oklch: dark ? 0.32 : 0.86, dark ? 0.010 : 0.014, dark ? 60 : 70),
                    Color(oklch: dark ? 0.28 : 0.82, dark ? 0.010 : 0.014, dark ? 60 : 70))
        case .warm:
            return (Color(oklch: dark ? 0.34 : 0.84, dark ? 0.020 : 0.022, 50),
                    Color(oklch: dark ? 0.30 : 0.80, dark ? 0.020 : 0.022, 50))
        case .cool:
            return (Color(oklch: dark ? 0.32 : 0.85, 0.018, 230),
                    Color(oklch: dark ? 0.28 : 0.81, 0.018, 230))
        case .olive:
            return (Color(oklch: dark ? 0.32 : 0.83, dark ? 0.030 : 0.026, 120),
                    Color(oklch: dark ? 0.28 : 0.79, dark ? 0.030 : 0.026, 120))
        case .rust:
            return (Color(oklch: dark ? 0.34 : 0.82, dark ? 0.040 : 0.034, 40),
                    Color(oklch: dark ? 0.30 : 0.78, dark ? 0.040 : 0.034, 40))
        case .char:
            return (Color(oklch: dark ? 0.22 : 0.45, dark ? 0.006 : 0.008, 60),
                    Color(oklch: dark ? 0.20 : 0.42, dark ? 0.006 : 0.008, 60))
        case .ecru:
            return (Color(oklch: dark ? 0.36 : 0.88, dark ? 0.014 : 0.018, 80),
                    Color(oklch: dark ? 0.32 : 0.84, dark ? 0.014 : 0.018, 80))
        }
    }
}

private struct StripeFill: View {
    let a: Color
    let b: Color
    var body: some View {
        Canvas { ctx, size in
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(a))
            let pitch: CGFloat = 16, band: CGFloat = 8
            let r = size.width + size.height
            ctx.translateBy(x: size.width / 2, y: size.height / 2)
            ctx.rotate(by: .degrees(45))
            ctx.translateBy(x: -r / 2, y: -r / 2)
            var x: CGFloat = 0
            while x < r {
                ctx.fill(Path(CGRect(x: x, y: 0, width: band, height: r)), with: .color(b))
                x += pitch
            }
        }
    }
}

struct Photo: View {
    var width: CGFloat? = nil
    /// nil = fill available height (full-bleed); otherwise a fixed point height.
    var height: CGFloat? = 220
    var tone: PhotoTone = .neutral
    var label: String = ""
    var radius: CGFloat = R.card
    var dark: Bool = false

    var body: some View {
        let (a, b) = tone.pair(dark: dark)
        let fg = Color(oklch: dark ? 0.62 : 0.50, 0.010, 60)
        StripeFill(a: a, b: b)
            .frame(maxWidth: width == nil ? .infinity : nil,
                   maxHeight: height == nil ? .infinity : nil)
            .frame(width: width, height: height)
            .overlay(
                Text(label.lowercased())
                    .font(F.mono(9))
                    .tracking(0.4)
                    .foregroundStyle(fg)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

// MARK: - Hairline helper

extension View {
    /// A 0.5px considered hairline border at the given radius.
    func hairline(_ color: Color, radius: CGFloat = R.card, width: CGFloat = 0.5) -> some View {
        overlay(RoundedRectangle(cornerRadius: radius).stroke(color, lineWidth: width))
    }
}

// MARK: - Btn

/// The considered button — a flat rectangle at 4px radius. Deliberately not an
/// iOS-default pill.
struct Btn: View {
    enum Kind { case primary, ghost, outline }
    var title: String
    var kind: Kind = .outline
    var dark: Bool = false
    var fullWidth: Bool = true
    var action: () -> Void = {}

    var body: some View {
        let ink = dark ? C.dink : C.ink
        let paper = dark ? C.dpaper : C.paper
        let line = dark ? C.dpaperLine : C.paperLine

        Button(action: action) {
            Text(title)
                .font(F.sans(15, .medium))
                .tracking(0.1)
                .foregroundStyle(kind == .primary ? paper : ink)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(kind == .primary ? ink : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: R.card))
                .overlay {
                    if kind == .outline {
                        RoundedRectangle(cornerRadius: R.card).stroke(line, lineWidth: 0.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - TabBar

/// Five items: Discover · Education · + (raised capture) · Planner · Wardrobe.
/// The raised + is the only fully-round element besides the capture button; it
/// launches the camera flow (never a persistent active state).
struct TabBar: View {
    var active: String = "wardrobe"
    var dark: Bool = false
    var onSelect: (String) -> Void = { _ in }
    var onCapture: () -> Void = {}

    private struct Item { let key, label, icon: String }
    private let items = [
        Item(key: "discover", label: "Discover",  icon: "compass"),
        Item(key: "edu",      label: "Education", icon: "book"),
        Item(key: "plus",     label: "",          icon: "plus"),
        Item(key: "planner",  label: "Planner",   icon: "hanger"),
        Item(key: "wardrobe", label: "Wardrobe",  icon: "photo"),
    ]

    var body: some View {
        let ink = dark ? C.dink : C.ink
        let mute = dark ? C.dinkMute : C.inkMute
        let accent = dark ? C.daccent : C.accent
        let paper = dark ? C.dpaper : C.paper
        let line = dark ? C.dpaperLine : C.paperLine

        HStack(alignment: .bottom) {
            ForEach(items, id: \.key) { it in
                if it.key == "plus" {
                    Button(action: onCapture) {
                        Sym(name: "plus", size: 22, color: paper, stroke: 2)
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(accent))
                            .offset(y: -14)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                } else {
                    let on = it.key == active
                    Button { onSelect(it.key) } label: {
                        VStack(spacing: 3) {
                            Sym(name: it.icon, size: 20, color: on ? ink : mute, stroke: on ? 1.9 : 1.4)
                            Text(it.label)
                                .font(F.sans(9.5, on ? .medium : .regular))
                                .tracking(0.2)
                                .foregroundStyle(on ? ink : mute)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(
            paper.overlay(alignment: .top) { Rectangle().fill(line).frame(height: 0.5) }
        )
    }
}
