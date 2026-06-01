//  DailyScreens.swift
//  Combin · Journey 2 — Daily mirror check
//
//  Camera default → capture → looking → result → expanded read. The most-used
//  flow in the app. Ported from screens-daily.jsx.

import SwiftUI

// MARK: - Shared chrome

/// A translucent dark control chip used over the camera viewport.
private struct CameraControl<Content: View>: View {
    var size: CGFloat = 38
    var solid: Bool = true
    @ViewBuilder var content: Content
    var body: some View {
        content
            .frame(width: size, height: size)
            .background(solid ? Overlay.inkShadow.opacity(0.32) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: R.card))
    }
}

// MARK: - S7 · Camera default state

struct CameraView: View {
    var onCapture: () -> Void
    var onBack: () -> Void = {}
    var onWardrobe: () -> Void = {}
    var onContext: () -> Void = {}

    var body: some View {
        ZStack {
            Photo(height: nil, tone: .char, label: "live viewport · front camera", radius: 0, dark: true)
                .overlay(FrameGuide())
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // top row — back · "headed where?" · wardrobe
                HStack(spacing: 10) {
                    Button(action: onBack) {
                        CameraControl { Sym(name: "chevron-l", size: 20, color: Overlay.paperWhite.opacity(0.92), stroke: 1.6) }
                    }.buttonStyle(.plain)
                    Spacer()
                    Button(action: onContext) {
                        HStack(spacing: 8) {
                            Text("headed").foregroundStyle(Overlay.paperWhite.opacity(0.65))
                            Text("where?").foregroundStyle(Overlay.paperWhite.opacity(0.78))
                            Sym(name: "chevron-d", size: 11, color: Overlay.paperWhite.opacity(0.78), stroke: 1.6)
                        }
                        .font(F.sans(12.5))
                        .padding(.vertical, 8).padding(.horizontal, 14)
                        .background(Overlay.inkShadow.opacity(0.32))
                        .clipShape(RoundedRectangle(cornerRadius: R.card))
                    }.buttonStyle(.plain)
                    Spacer()
                    Button(action: onWardrobe) {
                        CameraControl { Sym(name: "hanger", size: 20, color: Overlay.paperWhite.opacity(0.85), stroke: 1.5) }
                    }.buttonStyle(.plain)
                }
                .padding(.horizontal, 16).padding(.top, 8)

                Spacer(minLength: 0)

                // first-24h cue
                Text("Try it tomorrow morning, before you leave the house.")
                    .serif(15, color: Overlay.paperWhite.opacity(0.78), tracking: -0.05, lineHeight: 1.35)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 28).padding(.bottom, 12)

                // bottom row — gallery · capture · lock
                HStack {
                    CameraControl(size: 44) { Sym(name: "gallery-sm", size: 20, color: Overlay.paperWhite.opacity(0.85), stroke: 1.5) }
                    Spacer()
                    Button(action: onCapture) {
                        ZStack {
                            Circle().stroke(Overlay.paperWhite.opacity(0.92), lineWidth: 2).frame(width: 78, height: 78)
                            Circle().fill(C.accent).frame(width: 66, height: 66)
                        }
                        .frame(width: 78, height: 78)
                    }.buttonStyle(.plain)
                    Spacer()
                    CameraControl(size: 44, solid: false) { Sym(name: "lock", size: 16, color: Overlay.paperWhite.opacity(0.55), stroke: 1.5) }
                }
                .padding(.horizontal, 28).padding(.bottom, 18)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

// MARK: - S7b · Confirm context

struct ConfirmContextView: View {
    var onConfirm: () -> Void
    var onBack: () -> Void = {}

    private struct Cell { let key, icon, label: String }
    private let occasions: [Cell] = [
        .init(key: "work",   icon: "briefcase", label: "Work"),
        .init(key: "school", icon: "book",      label: "School"),
        .init(key: "dinner", icon: "glass",     label: "Dinner"),
        .init(key: "party",  icon: "sparkle",   label: "Party"),
        .init(key: "casual", icon: "tree",      label: "Casual"),
        .init(key: "travel", icon: "plane",     label: "Travel"),
        .init(key: "date",   icon: "heart",     label: "Date"),
        .init(key: "else",   icon: "pencil",    label: "Other"),
    ]
    private let weather: [Cell] = [
        .init(key: "sun",   icon: "sun",   label: "Clear"),
        .init(key: "cloud", icon: "cloud", label: "Cloudy"),
        .init(key: "rain",  icon: "rain",  label: "Rain"),
        .init(key: "snow",  icon: "snow",  label: "Snow"),
        .init(key: "wind",  icon: "wind",  label: "Windy"),
    ]
    @State private var occasion = "dinner"
    @State private var sky = "cloud"

    private let occCols = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        ZStack {
            Photo(height: nil, tone: .warm, label: "captured · frozen", radius: 0, dark: true)
                .overlay(Overlay.inkShadow.opacity(0.55))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Sym(name: "chevron-l", size: 20, color: Overlay.paperWhite.opacity(0.92), stroke: 1.6)
                            .frame(width: 38, height: 38)
                            .background(Overlay.inkShadow.opacity(0.45))
                            .clipShape(RoundedRectangle(cornerRadius: R.card))
                    }.buttonStyle(.plain)
                    Spacer()
                    MonoMarker("one quick thing", size: 9.5, color: Overlay.paperWhite.opacity(0.55))
                    Spacer()
                    Color.clear.frame(width: 38, height: 38)
                }
                .padding(.horizontal, 20).padding(.top, 10)

                Spacer(minLength: 0)

                sheet
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private var sheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule().fill(C.paperLine).frame(width: 36, height: 4)
                .frame(maxWidth: .infinity).padding(.bottom, 22)

            VStack(alignment: .leading, spacing: 6) {
                Text("Where are you headed?")
                    .serif(26, color: C.ink, tracking: -0.15, lineHeight: 1.18)
                Text("Helps me read the room. Skip if you'd rather not say.")
                    .sans(13, color: C.inkSoft)
            }
            .padding(.horizontal, 28)

            LazyVGrid(columns: occCols, spacing: 8) {
                ForEach(occasions, id: \.key) { o in
                    let on = o.key == occasion
                    Button { occasion = o.key } label: {
                        VStack(spacing: 6) {
                            Sym(name: o.icon, size: 20, color: on ? C.paper : C.ink, stroke: on ? 1.7 : 1.4)
                            Text(o.label).font(F.sans(11, on ? .medium : .regular)).tracking(0.1)
                                .foregroundStyle(on ? C.paper : C.ink)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13).padding(.horizontal, 6)
                        .background(on ? C.ink : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: R.card))
                        .overlay { if !on { RoundedRectangle(cornerRadius: R.card).stroke(C.paperLine, lineWidth: 0.5) } }
                    }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24).padding(.top, 20)

            HStack(alignment: .firstTextBaseline) {
                MonoMarker("weather · auto")
                Spacer()
                HStack(spacing: 6) {
                    Sym(name: "pin", size: 11, color: C.inkMute, stroke: 1.5)
                    Text("Brooklyn, NY").font(F.sans(11.5)).foregroundStyle(C.inkMute)
                }
            }
            .padding(.horizontal, 28).padding(.top, 26)

            HStack(spacing: 8) {
                ForEach(weather, id: \.key) { w in
                    let on = w.key == sky
                    Button { sky = w.key } label: {
                        VStack(spacing: 4) {
                            Sym(name: w.icon, size: 20, color: on ? C.paper : C.ink, stroke: on ? 1.7 : 1.4)
                            Text(w.label).font(F.sans(10.5, on ? .medium : .regular))
                                .foregroundStyle(on ? C.paper : C.ink)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11).padding(.horizontal, 4)
                        .background(on ? C.ink : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: R.card))
                        .overlay { if !on { RoundedRectangle(cornerRadius: R.card).stroke(C.paperLine, lineWidth: 0.5) } }
                    }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24).padding(.top, 12)

            Text("Cloudy, 14° · light wind from the east. Tap to change if that's not right.")
                .sans(12, color: C.inkSoft, lineHeight: 1.5)
                .padding(.horizontal, 28).padding(.top, 12)

            Btn(title: "Confirm & read it", kind: .primary, action: onConfirm)
                .padding(.horizontal, 24).padding(.top, 22)
        }
        .padding(.bottom, 24)
        .background(C.paper)
        .clipShape(.rect(topLeadingRadius: R.sheet, topTrailingRadius: R.sheet))
    }
}

// MARK: - S8 · Looking…

/// "A moment, not a spinner." The serif word with a soft ink-shimmer sweep.
struct LookingView: View {
    var body: some View {
        ZStack {
            Photo(height: nil, tone: .warm, label: "captured · frozen", radius: 0, dark: true)
                .scaleEffect(0.98)
                .overlay(Overlay.inkShadow.opacity(0.35))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 0) {
                    Capsule().fill(C.paperLine).frame(width: 36, height: 4)
                        .frame(maxWidth: .infinity).padding(.bottom, 26)
                    ShimmerWord()
                        .padding(.vertical, 36)
                    MonoMarker("a moment, not a spinner", tracking: 1.4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28).padding(.top, 14).padding(.bottom, 28)
                .background(C.paper)
                .clipShape(.rect(topLeadingRadius: R.sheet, topTrailingRadius: R.sheet))
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

private struct ShimmerWord: View {
    @State private var phase: CGFloat = -1
    private let word = "Looking…"
    var body: some View {
        Text(word)
            .serif(32, color: C.ink, tracking: -0.3, lineHeight: 1.1)
            .overlay {
                GeometryReader { geo in
                    LinearGradient(colors: [.clear, C.inkMute.opacity(0.95), .clear],
                                   startPoint: .leading, endPoint: .trailing)
                        .frame(width: geo.size.width)
                        .offset(x: phase * geo.size.width)
                }
                .mask(Text(word).serif(32, color: .black, tracking: -0.3))
            }
            .onAppear {
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - S9 · Vibe-check result

struct ResultView: View {
    var onClose: () -> Void = {}
    var onShare: () -> Void = {}
    var onTellMore: () -> Void
    var onGoWardrobe: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: onClose) { Sym(name: "x", size: 18, color: C.inkSoft, stroke: 1.6).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
                Spacer()
                Button(action: onShare) { Sym(name: "share", size: 18, color: C.inkSoft, stroke: 1.5).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            Photo(height: 228, tone: .warm, label: "user outfit · contained, editorial inset")
                .padding(.horizontal, 28).padding(.top, 8)

            Text("Three textures, one mood. That's the trick.")
                .serif(26, color: C.ink, tracking: -0.15, lineHeight: 1.22)
                .padding(.horizontal, 28).padding(.top, 32)

            // tweak card — quieter, sans, with thumbnail
            HStack(spacing: 14) {
                Photo(width: 56, height: 68, tone: .olive, radius: R.input)
                VStack(alignment: .leading, spacing: 6) {
                    MonoMarker("one tweak")
                    Text("Swap the belt for the olive one — pulls the palette tighter without changing the silhouette.")
                        .sans(13.5, color: C.ink, lineHeight: 1.45)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.init(top: 14, leading: 12, bottom: 14, trailing: 14))
            .overlay(alignment: .top) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
            .overlay(alignment: .bottom) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
            .padding(.horizontal, 28).padding(.top, 28)

            Spacer(minLength: 0)

            // bottom action chrome — low-contrast, present but not pushing
            Button(action: onTellMore) {
                HStack(spacing: 8) {
                    Text("Tell me more").font(F.sans(13)).foregroundStyle(C.inkSoft)
                    Sym(name: "chevron-d", size: 13, color: C.inkSoft, stroke: 1.5)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24).padding(.bottom, 6)

            Btn(title: "Go to the wardrobe", kind: .primary, action: onGoWardrobe)
                .padding(.horizontal, 24).padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - S10 · Expanded "tell me more"

struct ExpandedView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onDismiss) { Sym(name: "chevron-d", size: 18, color: C.inkSoft, stroke: 1.6).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("a longer read")
                Spacer()
                Sym(name: "dots", size: 18, color: C.inkMute).frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Three textures, one mood. That's the trick.")
                        .serif(22, color: C.ink, tracking: -0.1, lineHeight: 1.25)
                        .padding(.bottom, 18)

                    Text("The wool of the trousers, the cotton of the shirt, the suede of the loafers — three surfaces that catch light differently, and the whole outfit reads richer because of it.")
                        .serif(16, color: C.ink, lineHeight: 1.55)
                        .padding(.bottom, 14)

                    Text("You're working in a tight palette — sand, cream, brown — which is what makes the textures land. If everything were the same color in three identical fabrics, this would read flat. Instead it reads considered.")
                        .serif(16, color: C.inkSoft, lineHeight: 1.55)
                        .padding(.bottom, 18)

                    // inline wardrobe reference
                    HStack(spacing: 12) {
                        Photo(width: 48, height: 58, tone: .ecru, radius: R.input)
                        VStack(alignment: .leading, spacing: 3) {
                            MonoMarker("from your wardrobe", tracking: 1.2)
                            Text("The cream camp-collar shirt — last seen Apr 22.")
                                .sans(13, color: C.ink)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Sym(name: "chevron-r", size: 16, color: C.inkSoft, stroke: 1.6)
                    }
                    .padding(12)
                    .background(C.paperDeep)
                    .clipShape(RoundedRectangle(cornerRadius: R.card))
                    .padding(.bottom, 18)

                    Text("For the weather you've got — 14°, light wind — this is well-judged. You could push it warmer with the olive jacket, but you'd lose the texture story you've built.")
                        .serif(16, color: C.ink, lineHeight: 1.55)
                        .padding(.bottom, 14)

                    MonoMarker("one to try")
                        .padding(.top, 14)
                        .overlay(alignment: .top) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
                        .padding(.bottom, 8)

                    Text("Texture-mixing is one of the most reliable moves in menswear and one of the hardest to spot. Notice it in editorials and you'll start seeing it everywhere.")
                        .serif(15.5, color: C.inkSoft, lineHeight: 1.55)

                    Color.clear.frame(height: 40)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28).padding(.top, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}
