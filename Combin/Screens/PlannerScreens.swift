//  PlannerScreens.swift
//  Combin · Journey 3 — Outfit planner
//
//  Deliberate flow. Wardrobe-pull is the magic. The suggested-items shopping
//  surface is opt-in, walled off from AI feedback, and the only place in the app
//  prices appear. Ported from screens-planner.jsx.

import SwiftUI

// MARK: - Flow

struct PlannerFlow: View {
    @Binding var tab: String
    var onCapture: () -> Void

    private enum Page { case entry, context, suggestions, detail, shop }
    @State private var page: Page = .entry

    var body: some View {
        ZStack {
            switch page {
            case .entry:
                PlanEntryView(tab: $tab, onCapture: onCapture, onStart: { go(.context) })
                    .transition(.opacity)
            case .context:
                PlanContextView(onBack: { go(.entry) }, onSuggest: { go(.suggestions) })
                    .transition(.move(edge: .trailing))
            case .suggestions:
                SuggestionsView(onBack: { go(.context) }, onDetail: { go(.detail) })
                    .transition(.move(edge: .trailing))
            case .detail, .shop:
                SuggestionDetailView(onBack: { go(.suggestions) }, onShop: { go(.shop) })
                    .transition(.move(edge: .trailing))
            }
            if page == .shop {
                ShopSurfaceView(onDismiss: { go(.detail) })
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
        }
    }

    private func go(_ p: Page) { withAnimation(.easeInOut(duration: 0.34)) { page = p } }
}

// MARK: - Plan entry

private struct PlanEntryView: View {
    @Binding var tab: String
    var onCapture: () -> Void
    var onStart: () -> Void

    private let quick: [(PhotoTone, String)] = [
        (.char, "work · Tue 9am"), (.rust, "dinner · 7pm"),
        (.olive, "casual · this weekend"), (.ecru, "something else"),
    ]
    private let cols = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Planner").serif(22, color: C.ink, tracking: -0.2)
                Spacer()
                Sym(name: "dots", size: 18, color: C.inkSoft)
            }
            .padding(.horizontal, 24).padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Tell me where you're going and I'll put together two or three ideas, leaning on what's already in your closet.")
                        .sans(13, color: C.inkSoft, lineHeight: 1.55)
                        .padding(.leading, 12)
                        .overlay(alignment: .leading) { Rectangle().fill(C.paperLine).frame(width: 1) }
                        .padding(.horizontal, 24).padding(.top, 14)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("What are you\ngetting dressed for?")
                            .serif(28, color: C.ink, tracking: -0.25, lineHeight: 1.15)
                        Text("Skip whatever you don't feel like answering. Defaults are sensible.")
                            .sans(13, color: C.inkSoft, lineHeight: 1.5)
                    }
                    .padding(.horizontal, 28).padding(.top, 26)

                    MonoMarker("quick start").padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 12)
                    LazyVGrid(columns: cols, spacing: 10) {
                        ForEach(Array(quick.enumerated()), id: \.offset) { _, q in
                            Button(action: onStart) { Photo(height: 92, tone: q.0, label: q.1) }
                                .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)

                    Btn(title: "Build something from scratch", action: onStart)
                        .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 16)
                }
            }

            TabBar(active: "planner", onSelect: { tab = $0 }, onCapture: onCapture)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - Context

private struct PlanContextView: View {
    var onBack: () -> Void
    var onSuggest: () -> Void

    @State private var occasion = "Dinner"
    @State private var vibe = "Quiet"
    private let occasions = ["Work", "Date", "Dinner", "Casual", "Formal", "Travel", "Gym", "Event"]
    private let vibes = ["Polished", "Relaxed", "Statement", "Quiet", "Romantic", "Sharp"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) { Sym(name: "chevron-l", size: 18, color: C.inkSoft, stroke: 1.6).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("context")
                Spacer()
                Text("Skip").sans(13, color: C.inkSoft).frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MonoMarker("occasion").padding(.bottom, 10)
                    FlowLayout(spacing: 6, lineSpacing: 6) {
                        ForEach(occasions, id: \.self) { t in
                            Chip(title: t, on: t == occasion) { occasion = t }
                        }
                    }

                    MonoMarker("weather · auto").padding(.top, 22).padding(.bottom, 10)
                    HStack(spacing: 12) {
                        Sym(name: "sun-cloud", size: 22, color: C.ink)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("14° · partly cloudy · light wind").sans(14, color: C.ink)
                            Text("Brooklyn, NY · tonight").sans(12, color: C.inkMute)
                        }
                        Spacer()
                        Text("Edit").sans(12, color: C.inkSoft)
                    }
                    .padding(14)
                    .background(C.paperDeep)
                    .clipShape(RoundedRectangle(cornerRadius: R.card))

                    MonoMarker("vibe · optional").padding(.top, 22).padding(.bottom, 10)
                    FlowLayout(spacing: 6, lineSpacing: 6) {
                        ForEach(vibes, id: \.self) { t in
                            Chip(title: t, on: t == vibe) { vibe = t }
                        }
                    }

                    MonoMarker("dress code · optional").padding(.top, 22).padding(.bottom, 10)
                    Text("e.g. \"smart casual, no jeans\"")
                        .sans(13, color: C.inkMute)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12).padding(.horizontal, 14)
                        .overlay(RoundedRectangle(cornerRadius: R.input).stroke(C.paperLine, lineWidth: 0.5))
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 16)
            }

            Btn(title: "Suggest 3 outfits", kind: .primary, action: onSuggest)
                .padding(.horizontal, 24).padding(.top, 14).padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - Suggestions carousel

private struct SuggestionsView: View {
    var onBack: () -> Void
    var onDetail: () -> Void

    private let garments: [(PhotoTone, String, Bool)] = [
        (.ecru, "cream wool", true), (.warm, "camel coat", true),
        (.char, "wool trouser", false), (.rust, "leather boot", false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) { Sym(name: "chevron-l", size: 18, color: C.inkSoft, stroke: 1.6).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("dinner · 7pm · quiet")
                Spacer()
                Sym(name: "dots", size: 18, color: C.inkSoft).frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MonoMarker("look 1 of 3").padding(.bottom, 6)
                    Text("The camel coat anchors a quiet palette, the boots add a third texture without disrupting the formality.")
                        .serif(22, color: C.ink, tracking: -0.1, lineHeight: 1.22)

                    Photo(height: 224, tone: .ecru, label: "suggested look · 4 garments composed")
                        .padding(.top, 18)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(garments.enumerated()), id: \.offset) { _, g in
                                Photo(width: 64, height: 78, tone: g.0, label: "", radius: R.input)
                                    .overlay(alignment: .bottom) {
                                        if g.2 {
                                            Text("YOURS")
                                                .font(F.mono(8)).tracking(0.5)
                                                .foregroundStyle(C.paper)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 2)
                                                .background(Overlay.inkShadow.opacity(0.7))
                                                .padding(4)
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.top, 14)
                }
                .padding(.horizontal, 24)
            }

            HStack(spacing: 8) {
                Btn(title: "Make it warmer", action: {})
                Btn(title: "See full look", kind: .primary, action: onDetail)
            }
            .padding(.horizontal, 24).padding(.top, 14).padding(.bottom, 16)

            PageDots(count: 3, index: 0).padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - Suggestion detail

private struct SuggestionDetailView: View {
    var onBack: () -> Void
    var onShop: () -> Void

    private let yours: [(PhotoTone, String, String)] = [
        (.ecru, "Cream wool turtleneck", "Last seen Apr 22"),
        (.warm, "Camel overcoat", "Last seen Mar 10"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) { Sym(name: "chevron-l", size: 18, color: C.inkSoft, stroke: 1.6).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("look 1 · detail")
                Spacer()
                Sym(name: "bookmark", size: 16, color: C.inkMute, stroke: 1.5).frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Photo(height: 196, tone: .ecru, label: "composed look")
                    Text("The camel coat anchors a quiet palette, the boots add a third texture without disrupting the formality.")
                        .serif(19, color: C.ink, lineHeight: 1.3)
                        .padding(.top, 18)

                    MonoMarker("from your closet").padding(.top, 22).padding(.bottom, 8)
                    VStack(spacing: 0) {
                        ForEach(Array(yours.enumerated()), id: \.offset) { i, it in
                            HStack(spacing: 12) {
                                Photo(width: 44, height: 54, tone: it.0, radius: R.input)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(it.1).sans(13.5, color: C.ink)
                                    Text(it.2).sans(11, color: C.inkMute)
                                }
                                Spacer()
                                Sym(name: "chevron-r", size: 14, color: C.inkSoft, stroke: 1.6)
                            }
                            .padding(.vertical, 10)
                            .overlay(alignment: .top) { if i == 0 { Rectangle().fill(C.paperLine).frame(height: 0.5) } }
                            .overlay(alignment: .bottom) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
                        }
                    }

                    MonoMarker("and a piece you don't have").padding(.top, 20).padding(.bottom, 8)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("A dark, leather-soled boot — anything with structure. Think clean toe, low shaft.")
                            .serif(15, color: C.ink, lineHeight: 1.4)
                        Button(action: onShop) {
                            HStack {
                                Text("Shop suggestions").sans(12, color: C.inkSoft)
                                Spacer()
                                Sym(name: "chevron-d", size: 14, color: C.inkSoft, stroke: 1.6)
                            }
                            .padding(.top, 10)
                            .overlay(alignment: .top) { Rectangle().fill(C.paperLine).frame(height: 0.5).padding(.top, 0) }
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 2)
                    }
                    .padding(12)
                    .background(C.paperDeep)
                    .clipShape(RoundedRectangle(cornerRadius: R.card))
                }
                .padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 18)
            }

            Btn(title: "Save as tonight's look", kind: .primary, action: {})
                .padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - Shop surface (the only screen with prices)

private struct ShopSurfaceView: View {
    var onDismiss: () -> Void

    private let products: [(PhotoTone, String, String, String, String)] = [
        (.char, "Margiela", "Tabi leather Chelsea", "$890", "SSENSE"),
        (.rust, "Grenson", "Fred II derby boot", "$425", "Mr Porter"),
        (.warm, "Common Projects", "Achilles boot", "$615", "Brand direct"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onDismiss) { Sym(name: "chevron-d", size: 18, color: C.inkSoft, stroke: 1.6).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("suggested items")
                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Boots with structure.").serif(22, color: C.ink, tracking: -0.1, lineHeight: 1.22)
                    Text("Combin earns a commission on purchases through these links. We pick what to show based on your style, not on commission.")
                        .sans(11.5, color: C.inkSoft, lineHeight: 1.5)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(C.paperDeep)
                        .clipShape(RoundedRectangle(cornerRadius: R.input))
                        .padding(.top, 12)

                    VStack(spacing: 12) {
                        ForEach(Array(products.enumerated()), id: \.offset) { _, p in
                            HStack(spacing: 12) {
                                Photo(width: 88, height: 104, tone: p.0)
                                VStack(alignment: .leading, spacing: 0) {
                                    MonoMarker(p.1, tracking: 1.2)
                                    Text(p.2).serif(16, color: C.ink, lineHeight: 1.25).padding(.top, 2)
                                    Text(p.3).sans(13, color: C.ink).padding(.top, 6)
                                    Spacer(minLength: 6)
                                    HStack(spacing: 6) {
                                        Text("View on \(p.4)").sans(12, color: C.ink)
                                        Sym(name: "arrow-up", size: 11, color: C.ink, stroke: 1.6)
                                    }
                                    .padding(.vertical, 6).padding(.horizontal, 10)
                                    .overlay(RoundedRectangle(cornerRadius: R.input).stroke(C.paperLine, lineWidth: 0.5))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.top, 14)
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}
