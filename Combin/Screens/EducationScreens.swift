//  EducationScreens.swift
//  Combin · Journey 6 — Education
//
//  Editorial home. Daily Insight + Daily Puzzle as daily anchors. No commerce,
//  ever. Puzzle response is direction-language — never "wrong." Ported from
//  screens-education.jsx.

import SwiftUI

// MARK: - Flow

struct EducationFlow: View {
    @Binding var tab: String
    var onCapture: () -> Void

    private enum Page { case home, insight, play, response }
    @State private var page: Page = .home

    var body: some View {
        ZStack {
            switch page {
            case .home, .insight:
                EduHomeView(tab: $tab, onCapture: onCapture,
                            onInsight: { go(.insight) }, onPlay: { go(.play) })
                    .transition(.opacity)
            case .play:
                PuzzlePlayView(onClose: { go(.home) }, onSolve: { go(.response) })
                    .transition(.move(edge: .bottom))
            case .response:
                PuzzleResponseView(onBack: { go(.play) })
                    .transition(.opacity)
            }
            if page == .insight {
                DailyInsightView(onDismiss: { go(.home) })
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
        }
    }

    private func go(_ p: Page) { withAnimation(.easeInOut(duration: 0.34)) { page = p } }
}

// MARK: - Education home

private struct EduHomeView: View {
    @Binding var tab: String
    var onCapture: () -> Void
    var onInsight: () -> Void
    var onPlay: () -> Void

    private let feed: [(PhotoTone, String, String)] = [
        (.olive, "deep dive", "The Antwerp Six, in two collections."),
        (.cool, "film", "Bill Cunningham New York — streaming."),
        (.rust, "designer", "Grace Wales Bonner: an introduction."),
        (.char, "glossary", "What we mean when we say \"drape.\""),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Education").serif(22, color: C.ink, tracking: -0.2)
                Spacer()
                Sym(name: "dots", size: 18, color: C.inkSoft)
            }
            .padding(.horizontal, 24).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Things to read about fashion, plus a daily puzzle. Built to teach, not to sell.")
                        .sans(13, color: C.inkSoft, lineHeight: 1.55)
                        .padding(.leading, 12)
                        .overlay(alignment: .leading) { Rectangle().fill(C.paperLine).frame(width: 1) }
                        .padding(.horizontal, 24).padding(.top, 14)

                    MonoMarker("today · Wed 7 May").padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 14)

                    // Daily Insight
                    Button(action: onInsight) {
                        VStack(alignment: .leading, spacing: 0) {
                            Photo(height: 170, tone: .ecru, label: "daily insight · hero image")
                            MonoMarker("daily insight", color: C.accent).padding(.top, 14)
                            Text("Why the half-tuck reads as confidence.")
                                .serif(22, color: C.ink, tracking: -0.15, lineHeight: 1.2).padding(.top, 6)
                            Text("3 min read").sans(13, color: C.inkSoft).padding(.top, 6)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)

                    // Daily Puzzle card
                    puzzleCard.padding(.horizontal, 24).padding(.top, 24)

                    MonoMarker("this week").padding(.horizontal, 24).padding(.top, 6).padding(.bottom, 14)
                    VStack(spacing: 0) {
                        ForEach(Array(feed.enumerated()), id: \.offset) { i, it in
                            HStack(spacing: 14) {
                                Photo(width: 86, height: 110, tone: it.0, radius: R.input)
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoMarker(it.1)
                                    Text(it.2).serif(15.5, color: C.ink, lineHeight: 1.3)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 14)
                            .overlay(alignment: .top) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
                            .overlay(alignment: .bottom) { if i == feed.count - 1 { Rectangle().fill(C.paperLine).frame(height: 0.5) } }
                        }
                    }
                    .padding(.horizontal, 24)

                    Color.clear.frame(height: 24)
                }
            }

            TabBar(active: "edu", onSelect: { tab = $0 }, onCapture: onCapture)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    private var puzzleCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                MonoMarker("daily puzzle", color: C.accent)
                Spacer()
                Text("day 47").mono(9.5, color: C.inkMute, tracking: 1.2)
            }
            Text("Find the missing piece — make this serious, like a meeting where you want to be remembered.")
                .serif(19, color: C.ink, lineHeight: 1.3).padding(.top, 10)

            HStack(spacing: 6) {
                Photo(height: 78, tone: .ecru, radius: R.input)
                Photo(height: 78, tone: .char, radius: R.input)
                slotTile(height: 78, label: nil)
                Photo(height: 78, tone: .rust, radius: R.input)
            }
            .padding(.top, 14)

            HStack {
                Text("One per day. No timer.").sans(12, color: C.inkSoft)
                Spacer()
                Button(action: onPlay) {
                    Text("Play").font(F.sans(13, .medium)).foregroundStyle(C.paper)
                        .padding(.vertical, 8).padding(.horizontal, 14)
                        .background(C.ink)
                        .clipShape(RoundedRectangle(cornerRadius: R.input))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 14)
        }
        .padding(.init(top: 20, leading: 18, bottom: 18, trailing: 18))
        .background(C.paperDeep)
        .clipShape(RoundedRectangle(cornerRadius: R.card))
    }
}

/// The accent-bordered empty slot used in puzzles.
private func slotTile(height: CGFloat, label: String?) -> some View {
    VStack(spacing: 6) {
        Sym(name: "plus", size: label == nil ? 18 : 20, color: C.accent, stroke: 1.6)
        if let label {
            Text(label.uppercased()).font(F.mono(9)).tracking(1).foregroundStyle(C.accent)
                .multilineTextAlignment(.center)
        }
    }
    .frame(maxWidth: .infinity)
    .frame(height: height)
    .overlay(RoundedRectangle(cornerRadius: R.input).stroke(C.accent, lineWidth: 1.5))
}

// MARK: - Daily Insight (reader)

private struct DailyInsightView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onDismiss) { Sym(name: "chevron-d", size: 18, color: C.inkSoft, stroke: 1.6) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("daily insight")
                Spacer()
                Sym(name: "dots", size: 18, color: C.inkSoft)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Photo(height: 220, tone: .ecru, label: "hero · half-tuck reference")
                        .padding(.horizontal, 24)

                    MonoMarker("styling principle · 3 min").padding(.horizontal, 28).padding(.top, 24)
                    Text("Why the half-tuck reads as confidence.")
                        .serif(28, color: C.ink, tracking: -0.3, lineHeight: 1.15)
                        .padding(.horizontal, 28).padding(.top, 8)

                    VStack(alignment: .leading, spacing: 14) {
                        // raised initial (drop-cap approximation)
                        (Text("T").font(F.serif(28))
                         + Text("here are very few moves in dressing that come with so little risk and so much return. The half-tuck is one of them.").font(F.serif(16.5)))
                            .foregroundStyle(C.ink)
                            .lineSpacing(16.5 * (1.55 - 1.25))

                        Text("What it does, mechanically, is reveal the waistband — and with it, the line of the trouser. The eye reads structure where it would otherwise read drape. It's a small act of organization in an outfit that might otherwise look unfinished.")
                            .serif(16.5, color: C.ink, lineHeight: 1.55)

                        Text("What it doesn't do is read as care. It reads as someone who got dressed quickly, and well. That's the whole trick.")
                            .serif(16.5, color: C.inkSoft, lineHeight: 1.55)
                    }
                    .padding(.horizontal, 28).padding(.top, 20)

                    Color.clear.frame(height: 28)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - Daily Puzzle · play

private struct PuzzlePlayView: View {
    var onClose: () -> Void
    var onSolve: () -> Void

    private let base: [(PhotoTone?, String)] = [
        (.ecru, "cream camp shirt"), (.char, "wool trouser"),
        (nil, "something for the feet"), (.warm, "gold chain · simple"),
    ]
    private let cols = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onClose) { Sym(name: "x", size: 18, color: C.inkSoft, stroke: 1.6) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("daily puzzle · day 47")
                Spacer()
                Color.clear.frame(width: 18, height: 18)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            VStack(alignment: .leading, spacing: 0) {
                MonoMarker("the condition", color: C.accent)
                Text("Make this serious, like a meeting where you want to be remembered.")
                    .serif(24, color: C.ink, tracking: -0.2, lineHeight: 1.2).padding(.top, 8)
            }
            .padding(.horizontal, 28).padding(.top, 24)

            VStack(alignment: .leading, spacing: 0) {
                MonoMarker("the base · find what's missing").padding(.bottom, 10)
                LazyVGrid(columns: cols, spacing: 8) {
                    ForEach(Array(base.enumerated()), id: \.offset) { _, g in
                        if let tone = g.0 {
                            Photo(height: 130, tone: tone, radius: R.input)
                                .overlay(alignment: .bottom) {
                                    Text(g.1)
                                        .font(F.mono(9)).tracking(0.4)
                                        .foregroundStyle(C.paper)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 3).padding(.horizontal, 6)
                                        .background(Overlay.inkShadow.opacity(0.62))
                                        .padding(6)
                                }
                        } else {
                            Button(action: onSolve) { slotTile(height: 130, label: g.1) }
                                .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 24).padding(.top, 28)

            Spacer(minLength: 0)

            Button(action: onSolve) {
                Text("Search the closet · type or browse")
                    .sans(13, color: C.inkMute)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 14).padding(.horizontal, 16)
                    .overlay(RoundedRectangle(cornerRadius: R.input).stroke(C.paperLine, lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24).padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - Daily Puzzle · response

private struct PuzzleResponseView: View {
    var onBack: () -> Void

    private let alts: [(PhotoTone, String, String)] = [
        (.char, "CONSERVATIVE", "Black oxford. Polished. Reads serious without trying."),
        (.rust, "INTERESTING", "Brown brogue. Brings a third texture, lifts the formality."),
        (.olive, "RISKIER", "Suede loafer. Quiet, but the right kind of quiet."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) { Sym(name: "chevron-l", size: 18, color: C.inkSoft, stroke: 1.6) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("daily puzzle")
                Spacer()
                Color.clear.frame(width: 18, height: 18)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MonoMarker("you picked").padding(.bottom, 8)
                    HStack(spacing: 14) {
                        Photo(width: 84, height: 104, tone: .ecru, radius: R.input)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("White canvas sneaker").serif(16, color: C.ink, lineHeight: 1.25)
                            Text("Found in: Common Projects archive").sans(12, color: C.inkSoft)
                        }
                    }

                    Text("Those soften the whole thing — the outfit suddenly reads weekend, not boardroom.")
                        .serif(22, color: C.ink, tracking: -0.15, lineHeight: 1.3).padding(.top, 28)
                    Text("The canvas pulls against the wool and undoes the formality the trousers are doing. For \"serious,\" look for leather, darker, with a clean toe.")
                        .serif(16, color: C.inkSoft, lineHeight: 1.55).padding(.top, 16)

                    MonoMarker("three that would have worked")
                        .padding(.top, 28).padding(.bottom, 12)
                        .overlay(alignment: .top) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 8) {
                            ForEach(Array(alts.enumerated()), id: \.offset) { _, it in
                                VStack(alignment: .leading, spacing: 0) {
                                    Photo(height: 140, tone: it.0, radius: R.input)
                                    Text(it.1).font(F.mono(9)).tracking(1.4).foregroundStyle(C.accent).padding(.top, 8)
                                    Text(it.2).serif(13, color: C.ink, lineHeight: 1.4).padding(.top, 4)
                                }
                                .frame(width: 220)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24).padding(.top, 20)
            }

            Btn(title: "Tomorrow's puzzle drops at 7am", kind: .primary, action: onBack)
                .padding(.horizontal, 24).padding(.top, 8).padding(.bottom, 26)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}
