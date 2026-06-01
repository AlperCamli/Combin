//  OnboardingScreens.swift
//  Combin · Journey 1 — Onboarding
//
//  First-launch through first vibe-check. The trust screen carries more weight
//  than any other screen here. Ported from screens-onboarding.jsx and
//  screens-daily.jsx (S6 first result).

import SwiftUI

// MARK: - S1 · Welcome

/// Full-bleed image, single sentence, single CTA.
struct WelcomeView: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // full-bleed photo + subtle bottom scrim
            Photo(height: nil, tone: .rust, label: "art-directed editorial — real person, considered styling", radius: 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    LinearGradient(stops: [
                        .init(color: .clear, location: 0.5),
                        .init(color: Overlay.inkShadow.opacity(0.55), location: 1.0),
                    ], startPoint: .top, endPoint: .bottom)
                )
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("Your stylist\nin your pocket.")
                    .serif(36, color: Overlay.paperWhite, tracking: -0.3, lineHeight: 1.08)
                    .padding(.bottom, 12)
                Text("Honest when you ask. Kind every time.")
                    .sans(14, color: Overlay.paperWhite.opacity(0.78))
                    .padding(.bottom, 32)

                Button(action: onContinue) {
                    HStack(spacing: 10) {
                        Text("Let's go").font(F.sans(15, .medium))
                        Sym(name: "arrow-up", size: 14, color: C.ink, stroke: 1.8)
                    }
                    .foregroundStyle(C.ink)
                    .padding(.vertical, 14).padding(.horizontal, 22)
                    .background(C.paper)
                    .clipShape(RoundedRectangle(cornerRadius: R.card))
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.bottom, 44)
        }
        .background(C.ink.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

// MARK: - S2 · Trust & privacy

struct TrustView: View {
    var onGotIt: () -> Void
    var onMore: () -> Void

    private let items: [(icon: String, text: String)] = [
        ("lock",   "Your photos stay on your device when possible."),
        ("shield", "What we send to the AI is encrypted."),
        ("trash",  "Delete any photo, any time."),
        ("no-ad",  "We never sell your data, and there are no ads."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                MonoMarker("⟶ One thing first", tracking: 1.2)
                    .padding(.bottom, 14)
                Text("A few words on\nhow this works.")
                    .serif(28, color: C.ink, tracking: -0.2, lineHeight: 1.15)
            }
            .padding(.horizontal, 28)
            .padding(.top, 32)

            VStack(alignment: .leading, spacing: 22) {
                ForEach(items, id: \.text) { it in
                    HStack(alignment: .top, spacing: 14) {
                        Sym(name: it.icon, size: 20, color: C.ink, stroke: 1.5)
                            .padding(.top, 2)
                        Text(it.text)
                            .sans(15.5, color: C.ink, lineHeight: 1.45)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 36)

            Spacer(minLength: 0)

            VStack(spacing: 8) {
                Btn(title: "Got it", kind: .primary, action: onGotIt)
                Btn(title: "Tell me more", kind: .ghost, action: onMore)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - S3 · Taste calibration

struct TasteView: View {
    var onContinue: () -> Void

    private struct Card { let tone: PhotoTone; let label: String }
    private let cards: [Card] = [
        .init(tone: .warm,  label: "tailored · warm tones"),
        .init(tone: .olive, label: "workwear · olive · earthy"),
        .init(tone: .char,  label: "monochrome · charcoal"),
        .init(tone: .ecru,  label: "soft · linen · ecru"),
        .init(tone: .cool,  label: "sport · technical · cool"),
        .init(tone: .rust,  label: "evening · jewel · rust"),
    ]
    @State private var selected: Set<Int> = [0, 2, 4]

    private let cols = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MonoMarker("02 / 04", tracking: 1.2)
                .padding(.horizontal, 24).padding(.top, 24)

            VStack(alignment: .leading, spacing: 6) {
                Text("Which feel like you?")
                    .serif(26, color: C.ink, tracking: -0.2, lineHeight: 1.15)
                Text("Tap any that resonate. Pick none and we'll figure it out together.")
                    .sans(13, color: C.inkSoft)
            }
            .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 18)

            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(Array(cards.enumerated()), id: \.offset) { i, card in
                    Button {
                        if selected.contains(i) { selected.remove(i) } else { selected.insert(i) }
                    } label: {
                        Photo(height: 170, tone: card.tone, label: card.label)
                            .overlay {
                                if selected.contains(i) {
                                    RoundedRectangle(cornerRadius: R.card).stroke(C.ink, lineWidth: 2)
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                if selected.contains(i) {
                                    Sym(name: "check", size: 14, color: C.paper, stroke: 2)
                                        .frame(width: 22, height: 22)
                                        .background(Circle().fill(C.ink))
                                        .padding(8)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)

            HStack {
                Spacer()
                Button(action: onContinue) {
                    HStack(spacing: 10) {
                        Text("Continue").font(F.sans(15, .medium))
                        Sym(name: "chevron-r", size: 14, color: C.paper, stroke: 2)
                    }
                    .foregroundStyle(C.paper)
                    .padding(.vertical, 12).padding(.horizontal, 20)
                    .background(C.ink)
                    .clipShape(RoundedRectangle(cornerRadius: R.card))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - S4 · Permissions

struct PermissionsView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                MonoMarker("03 / 04", tracking: 1.2).padding(.bottom, 14)
                Text("One small ask.")
                    .serif(26, color: C.ink, tracking: -0.2, lineHeight: 1.15)
                Text("Optional. The app works without it. We'll ask about notifications later, once you're in the habit.")
                    .sans(13.5, color: C.inkSoft, lineHeight: 1.5)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 28).padding(.top, 32)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 10) {
                        Sym(name: "sun-cloud", size: 18, color: C.ink)
                        Text("Location").font(F.sans(15, .medium)).foregroundStyle(C.ink)
                    }
                    Spacer()
                    Button(action: onContinue) {
                        Text("Allow")
                            .font(F.sans(12, .medium)).foregroundStyle(C.ink)
                            .padding(.vertical, 6).padding(.horizontal, 12)
                            .hairline(C.paperLine, radius: R.card)
                    }
                    .buttonStyle(.plain)
                }
                Text("So we recommend based on the weather.")
                    .sans(13.5, color: C.inkSoft, lineHeight: 1.45)
            }
            .padding(.init(top: 18, leading: 18, bottom: 16, trailing: 18))
            .hairline(C.paperLine, radius: R.card)
            .padding(.horizontal, 24).padding(.top, 28)

            Spacer(minLength: 0)

            Btn(title: "Maybe later", kind: .ghost, action: onContinue)
                .padding(.horizontal, 28).padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - S5 · First photo capture

struct FirstCaptureView: View {
    var onCapture: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Photo(height: nil, tone: .char, label: "live camera viewport · front-facing", radius: 0, dark: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    LinearGradient(stops: [
                        .init(color: .black.opacity(0.45), location: 0.0),
                        .init(color: .black.opacity(0.05), location: 0.30),
                        .init(color: .black.opacity(0.05), location: 0.60),
                        .init(color: .black.opacity(0.70), location: 1.0),
                    ], startPoint: .top, endPoint: .bottom)
                )
                .overlay(FrameGuide())
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    MonoMarker("04 / 04 · First read", color: Overlay.paperWhite.opacity(0.55), tracking: 1.2)
                        .padding(.bottom, 10)
                    Text("Check your fit")
                        .serif(24, color: Overlay.paperWhite.opacity(0.92), tracking: -0.1, lineHeight: 1.18)
                    Text("The outfit just needs to be visible.")
                        .sans(13, color: Overlay.paperWhite.opacity(0.65))
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28).padding(.top, 20)

                Spacer(minLength: 0)

                VStack(spacing: 10) {
                    Button(action: onCapture) {
                        Text("Take a photo")
                            .font(F.sans(15, .medium)).foregroundStyle(C.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14).padding(.horizontal, 20)
                            .background(C.paper)
                            .clipShape(RoundedRectangle(cornerRadius: R.card))
                    }.buttonStyle(.plain)
                    Button(action: onCapture) {
                        Text("Use a recent one")
                            .font(F.sans(15, .medium)).foregroundStyle(Overlay.paperWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14).padding(.horizontal, 20)
                            .hairline(Overlay.paperWhite.opacity(0.45), radius: R.card)
                    }.buttonStyle(.plain)
                }
                .padding(.horizontal, 24).padding(.bottom, 36)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

// MARK: - S6 · First vibe-check result

/// Same as the standard vibe-check, but slightly warmer and with one tiny
/// educational note. Ends on the handoff line that pivots into the app.
struct FirstResultView: View {
    var onShowCloset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Color.clear.frame(width: 36, height: 36)
                Spacer()
                Sym(name: "lock", size: 14, color: C.inkMute, stroke: 1.5)
                    .frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            Photo(height: 210, tone: .ecru, label: "first photo · editorial inset")
                .padding(.horizontal, 28).padding(.top, 8)

            Text("Quiet confidence — the kind people remember without knowing why.")
                .serif(26, color: C.ink, tracking: -0.15, lineHeight: 1.22)
                .padding(.horizontal, 28).padding(.top, 32)

            VStack(alignment: .leading, spacing: 8) {
                MonoMarker("a small note", color: C.accent)
                Text("Linen reads softer than cotton in this light — the wrinkles you're worrying about are doing work for you.")
                    .sans(13.5, color: C.inkSoft, lineHeight: 1.55)
                    .padding(.leading, 12)
                    .overlay(alignment: .leading) {
                        Rectangle().fill(C.paperLine).frame(width: 1)
                    }
            }
            .padding(.horizontal, 28).padding(.top, 26)

            Spacer(minLength: 0)

            (Text("I just learned a few pieces of your closet. ")
                .foregroundStyle(C.ink)
             + Text("Want to see?").foregroundStyle(C.accent))
                .font(F.serif(16))
                .tracking(-0.05)
                .lineSpacing(16 * (1.35 - 1.25))
                .padding(.horizontal, 28).padding(.top, 20)

            Btn(title: "Show me my closet", kind: .primary, action: onShowCloset)
                .padding(.horizontal, 24).padding(.top, 14).padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}
