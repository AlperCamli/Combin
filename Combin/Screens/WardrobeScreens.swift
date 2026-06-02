//  WardrobeScreens.swift
//  Combin · Journey 4 — Wardrobe (the user's fashion history)
//
//  Default landing is Looks — a photo grid of vibe-checks. Items mode lives
//  behind a toggle. First-visit framing sits inline, no modal. Ported from
//  screens-wardrobe.jsx.

import SwiftUI

// MARK: - Flow

struct WardrobeFlow: View {
    @Binding var tab: String
    var onCapture: () -> Void

    private enum Page { case root, detail }
    @State private var page: Page = .root
    @State private var mode = "Looks"
    @State private var correcting = false

    var body: some View {
        ZStack {
            switch page {
            case .root:
                WardrobeRoot(mode: $mode, tab: $tab, onCapture: onCapture,
                             onOpenItem: { withAnimation(.easeInOut(duration: 0.32)) { page = .detail } })
                    .transition(.opacity)
            case .detail:
                ItemDetailView(onBack: { withAnimation(.easeInOut(duration: 0.32)) { page = .root } },
                               onCorrect: { withAnimation(.easeInOut(duration: 0.3)) { correcting = true } })
                    .transition(.move(edge: .trailing))
            }
            if correcting {
                InlineCorrectView(onDismiss: { withAnimation(.easeInOut(duration: 0.3)) { correcting = false } })
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
    }
}

// MARK: - Root (Looks grid + Items mode)

private struct WardrobeRoot: View {
    @Binding var mode: String
    @Binding var tab: String
    var onCapture: () -> Void
    var onOpenItem: () -> Void

    private let looks: [PhotoTone] = [.ecru, .warm, .olive, .char, .rust, .cool, .warm, .ecru, .char, .olive, .cool, .rust]
    private let cats: [(name: String, count: Int, items: [PhotoTone])] = [
        ("tops", 14, [.ecru, .warm, .cool, .olive]),
        ("outerwear", 6, [.warm, .char, .olive]),
        ("bottoms", 9, [.char, .rust, .ecru, .cool]),
        ("shoes", 5, [.rust, .char]),
    ]
    private let grid3 = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    private let grid4 = Array(repeating: GridItem(.flexible(), spacing: 6), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Wardrobe").font(F.sans(13, .medium)).foregroundStyle(C.inkSoft)
                Spacer()
                Sym(name: "dots", size: 16, color: C.inkMute).frame(width: 32, height: 32)
            }
            .padding(.horizontal, 24).padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if mode == "Looks" {
                        Text("This is what I caught from your photo. Every vibe-check adds to it.")
                            .serif(22, color: C.ink, tracking: -0.1, lineHeight: 1.25)
                            .padding(.horizontal, 28).padding(.top, 24).padding(.bottom, 8)
                    }

                    HStack(alignment: .firstTextBaseline) {
                        MonoMarker("your fashion history", size: 10)
                        Spacer()
                        MonoMarker(mode == "Looks" ? "1 look · 4 items" : "12 looks · 34 items", size: 10, tracking: 0.6)
                    }
                    .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 14)

                    SegmentedToggle(options: ["Looks", "Items"], selection: $mode)
                        .padding(.horizontal, 24).padding(.bottom, 14)

                    if mode == "Looks" {
                        LazyVGrid(columns: grid3, spacing: 2) {
                            ForEach(Array(looks.enumerated()), id: \.offset) { i, tone in
                                Button(action: onOpenItem) {
                                    Photo(height: 118, tone: tone, label: i == 0 ? "just now" : "", radius: 0)
                                        .overlay(alignment: .topLeading) {
                                            if i == 0 {
                                                Text("JUST NOW")
                                                    .font(F.mono(9)).tracking(0.8)
                                                    .foregroundStyle(C.ink)
                                                    .padding(.vertical, 3).padding(.horizontal, 6)
                                                    .background(C.paper.opacity(0.92))
                                                    .clipShape(RoundedRectangle(cornerRadius: R.input))
                                                    .padding(6)
                                            }
                                        }
                                        .overlay { if i > 0 { C.paper.opacity(0.55) } }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 14)

                        Text("Keep taking vibe-checks and this fills in. After a couple of weeks, I'll start spotting things you already own.")
                            .sans(13, color: C.inkSoft, lineHeight: 1.55)
                            .padding(.leading, 12)
                            .overlay(alignment: .leading) { Rectangle().fill(C.paperLine).frame(width: 1) }
                            .padding(.horizontal, 28).padding(.top, 22).padding(.bottom, 28)
                    } else {
                        VStack(alignment: .leading, spacing: 22) {
                            ForEach(cats, id: \.name) { cat in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .firstTextBaseline) {
                                        MonoMarker(cat.name)
                                        Spacer()
                                        Text("\(cat.count)").font(F.mono(10)).foregroundStyle(C.inkMute)
                                    }
                                    LazyVGrid(columns: grid4, spacing: 6) {
                                        ForEach(Array(cat.items.enumerated()), id: \.offset) { _, t in
                                            Button(action: onOpenItem) { Photo(height: 78, tone: t, radius: R.input) }
                                                .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24).padding(.top, 6).padding(.bottom, 16)
                    }
                }
            }

            TabBar(active: "wardrobe", onSelect: { tab = $0 }, onCapture: onCapture)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - Item detail

private struct ItemDetailView: View {
    var onBack: () -> Void
    var onCorrect: () -> Void

    private let attrs: [(String, String)] = [
        ("Color", "Camel"), ("Type", "Overcoat"), ("Material", "Wool blend"), ("Formality", "Smart"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) { Sym(name: "chevron-l", size: 18, color: C.inkSoft, stroke: 1.6).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("your closet")
                Spacer()
                Sym(name: "dots", size: 18, color: C.inkSoft).frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Photo(height: 232, tone: .warm, label: "extracted source · the camel overcoat")
                        .padding(.horizontal, 28).padding(.top, 12)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Camel overcoat").serif(22, color: C.ink, tracking: -0.1, lineHeight: 1.2)
                        Text("Worn 4 times · last seen Mar 10").sans(12.5, color: C.inkSoft)
                    }
                    .padding(.horizontal, 28).padding(.top, 20)

                    MonoMarker("what i see")
                        .padding(.horizontal, 28).padding(.top, 20).padding(.bottom, 8)
                    VStack(spacing: 0) {
                        ForEach(Array(attrs.enumerated()), id: \.offset) { i, kv in
                            HStack {
                                Text(kv.0).sans(13.5, color: C.ink)
                                Spacer()
                                Text(kv.1).sans(13.5, color: C.inkSoft)
                                Button(action: onCorrect) {
                                    Text("Edit").font(F.sans(11)).foregroundStyle(C.accent)
                                        .padding(.vertical, 2).padding(.horizontal, 8)
                                        .overlay(RoundedRectangle(cornerRadius: R.input).stroke(C.accent, lineWidth: 0.5))
                                }.buttonStyle(.plain)
                            }
                            .padding(.vertical, 12)
                            .overlay(alignment: .top) { if i == 0 { Rectangle().fill(C.paperLine).frame(height: 0.5) } }
                            .overlay(alignment: .bottom) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
                        }
                    }
                    .padding(.horizontal, 24)

                    MonoMarker("worn in 4 looks")
                        .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 8)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach([PhotoTone.warm, .ecru, .olive, .cool].indices, id: \.self) { i in
                                Photo(width: 86, height: 108, tone: [PhotoTone.warm, .ecru, .olive, .cool][i], radius: R.input)
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    HStack(spacing: 8) {
                        Btn(title: "Mark as donated", action: {})
                        Btn(title: "Hide", action: {})
                    }
                    .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 30)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - Inline correction (sheet over a dimmed screen)

private struct InlineCorrectView: View {
    var onDismiss: () -> Void
    @State private var pick = "Navy"
    private let options = ["Black", "Navy", "Charcoal", "Something else"]

    var body: some View {
        ZStack(alignment: .bottom) {
            // dimmed result behind
            Color.black.opacity(0.001).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                Photo(height: 210, tone: .warm)
                Text("Try the black jacket from last week — pulls the palette tighter.")
                    .serif(22, color: C.ink, lineHeight: 1.2)
                    .padding(.top, 24)
            }
            .padding(.horizontal, 28).padding(.top, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .opacity(0.35)
            .background(C.paper.ignoresSafeArea())

            // sheet
            VStack(alignment: .leading, spacing: 0) {
                Capsule().fill(C.paperLine).frame(width: 36, height: 4)
                    .frame(maxWidth: .infinity).padding(.bottom, 18)
                MonoMarker("fix in place").padding(.bottom, 10)
                Text("The jacket is —").serif(19, color: C.ink, lineHeight: 1.25).padding(.bottom, 14)

                HStack(alignment: .top, spacing: 10) {
                    Photo(width: 64, height: 78, tone: .char, radius: R.input)
                    VStack(spacing: 6) {
                        ForEach(options, id: \.self) { opt in
                            let on = opt == pick
                            Button { pick = opt } label: {
                                HStack {
                                    Text(opt).font(F.sans(13.5, on ? .medium : .regular)).foregroundStyle(on ? C.paper : C.ink)
                                    Spacer()
                                    if on { Sym(name: "check", size: 14, color: C.paper, stroke: 2) }
                                }
                                .padding(.vertical, 10).padding(.horizontal, 12)
                                .background(on ? C.ink : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: R.input))
                                .overlay { if !on { RoundedRectangle(cornerRadius: R.input).stroke(C.paperLine, lineWidth: 0.5) } }
                            }.buttonStyle(.plain)
                        }
                    }
                }
                .padding(.bottom, 18)

                Btn(title: "Got it — try again", kind: .primary, action: onDismiss)
            }
            .padding(.horizontal, 24).padding(.top, 14).padding(.bottom, 28)
            .background(C.paper)
            .clipShape(.rect(topLeadingRadius: R.sheet, topTrailingRadius: R.sheet))
        }
        .preferredColorScheme(.light)
    }
}
