//  DailyScreens.swift
//  Combin · Journey 2 — Daily mirror check
//
//  Camera default → capture → "Thinking…" → result → expanded read. The most-used
//  flow in the app, and the heart of the MVP (the Daily Vibe Check). The camera now
//  uses a real AVCaptureSession (with a gallery fallback), and the looking/result
//  screens are driven by VibeCheckViewModel rather than timers + hardcoded copy.

import SwiftUI
import UIKit

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

/// Real capture. Shows a live AVCaptureSession preview where available (device), and
/// falls back to the striped placeholder on the simulator — the gallery path works
/// everywhere. Delivers a captured/picked `UIImage` to `onCapture`.
struct CameraView: View {
    var onCapture: (UIImage) -> Void
    var onBack: () -> Void = {}
    var onWardrobe: () -> Void = {}
    var onContext: () -> Void = {}   // "headed where?" — reserved for post-MVP context capture

    @StateObject private var camera = CameraController()
    @State private var showPicker = false
    @State private var capturing = false

    private var liveCamera: Bool { camera.isAuthorized && camera.isAvailable }

    var body: some View {
        ZStack {
            // viewport
            Group {
                if liveCamera {
                    CameraPreview(session: camera.session).ignoresSafeArea()
                } else {
                    Photo(height: nil, tone: .char, label: "camera unavailable here · use the gallery",
                          radius: 0, dark: true)
                        .ignoresSafeArea()
                }
            }
            .overlay(FrameGuide())

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

                // first-24h cue / fallback guidance
                Text(liveCamera
                     ? "Show me what you're wearing today."
                     : "Pick a recent photo and I'll read the outfit.")
                    .serif(15, color: Overlay.paperWhite.opacity(0.78), tracking: -0.05, lineHeight: 1.35)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 28).padding(.bottom, 12)

                // bottom row — gallery · capture · lock
                HStack {
                    Button { showPicker = true } label: {
                        CameraControl(size: 44) { Sym(name: "gallery-sm", size: 20, color: Overlay.paperWhite.opacity(0.85), stroke: 1.5) }
                    }.buttonStyle(.plain)

                    Spacer()

                    Button(action: capture) {
                        ZStack {
                            Circle().stroke(Overlay.paperWhite.opacity(0.92), lineWidth: 2).frame(width: 78, height: 78)
                            Circle().fill(C.accent).frame(width: 66, height: 66)
                            if capturing {
                                ProgressView().tint(Overlay.paperWhite)
                            }
                        }
                        .frame(width: 78, height: 78)
                        .opacity(liveCamera ? 1 : 0.4)
                    }
                    .buttonStyle(.plain)
                    .disabled(!liveCamera || capturing)

                    Spacer()
                    CameraControl(size: 44, solid: false) { Sym(name: "lock", size: 16, color: Overlay.paperWhite.opacity(0.55), stroke: 1.5) }
                }
                .padding(.horizontal, 28).padding(.bottom, 18)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .task {
            await camera.configure()
            camera.start()
        }
        .onDisappear { camera.stop() }
        .sheet(isPresented: $showPicker) {
            PhotoPicker(onPick: { onCapture($0) })
                .ignoresSafeArea()
        }
    }

    private func capture() {
        guard liveCamera, !capturing else { return }
        capturing = true
        Task {
            defer { capturing = false }
            if let image = try? await camera.capture() {
                onCapture(image)
            }
        }
    }
}

// MARK: - S7b · Confirm context  (reserved — not in the MVP core loop)

/// Optional occasion/weather capture. Kept from the Tier-1 design but NOT wired into
/// the MVP loop (the plan's core loop is camera → thinking → result). Re-route the
/// camera's "headed where?" pill here when context capture is built post-MVP.
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

/// "A moment, not a spinner." The captured photo sits frozen behind a paper sheet; a
/// cycling serif phrase and a hairline that writes itself stand in for a spinner.
struct LookingView: View {
    var image: UIImage? = nil

    @State private var phraseIndex = 0
    @State private var lineProgress: CGFloat = 0

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 0) {
                    Capsule().fill(C.paperLine).frame(width: 36, height: 4)
                        .frame(maxWidth: .infinity).padding(.bottom, 26)

                    Text(VibeVoice.loadingPhrases[phraseIndex])
                        .serif(30, color: C.ink, tracking: -0.3, lineHeight: 1.1)
                        .id(phraseIndex)
                        .transition(.opacity)
                        .padding(.bottom, 24)

                    GeometryReader { geo in
                        Rectangle()
                            .fill(C.inkMute.opacity(0.7))
                            .frame(width: max(0, geo.size.width * lineProgress), height: 1)
                    }
                    .frame(height: 1)
                    .padding(.bottom, 26)

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
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                lineProgress = 1
            }
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                withAnimation(.easeInOut(duration: 0.5)) {
                    phraseIndex = (phraseIndex + 1) % VibeVoice.loadingPhrases.count
                }
            }
        }
    }

    @ViewBuilder private var background: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                // Pin to the container and clip; otherwise scaledToFill overflows and
                // stretches the ZStack wider than the screen, shoving the leading-aligned
                // sheet content off-screen left.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .overlay(Overlay.inkShadow.opacity(0.4))
                .ignoresSafeArea()
        } else {
            Photo(height: nil, tone: .warm, label: "captured · frozen", radius: 0, dark: true)
                .scaleEffect(0.98)
                .overlay(Overlay.inkShadow.opacity(0.35))
                .ignoresSafeArea()
        }
    }
}

// MARK: - S9 · Vibe-check result

/// The hero moment. The one-liner reveals word-by-word; the optional tweak fades in
/// when Stage 2 lands. On a failure, the same screen carries the warm fallback copy
/// and a single "Try another photo" action.
struct ResultView: View {
    @ObservedObject var vm: VibeCheckViewModel
    var onClose: () -> Void = {}
    var onShare: () -> Void = {}
    var onTellMore: () -> Void = {}
    var onGoWardrobe: () -> Void = {}
    var onRetry: () -> Void = {}

    private var failureMessage: String? {
        if case .failed(let message) = vm.phase { return message }
        return nil
    }

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

            outfitInset(height: 228)
                .padding(.horizontal, 28).padding(.top, 8)

            // hero one-liner (or the warm failure copy)
            Text(failureMessage ?? vm.revealedText)
                .serif(26, color: C.ink, tracking: -0.15, lineHeight: 1.22)
                .animation(.easeOut(duration: 0.15), value: vm.revealedText)
                .padding(.horizontal, 28).padding(.top, 32)

            // tweak card — only on success, only when a tweak exists
            if failureMessage == nil, vm.tweakReady, let tweak = vm.tweakText {
                HStack(spacing: 14) {
                    outfitThumb()
                    VStack(alignment: .leading, spacing: 6) {
                        MonoMarker("one tweak")
                        Text(tweak)
                            .sans(13.5, color: C.ink, lineHeight: 1.45)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.init(top: 14, leading: 12, bottom: 14, trailing: 14))
                .overlay(alignment: .top) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
                .overlay(alignment: .bottom) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
                .padding(.horizontal, 28).padding(.top, 28)
                .transition(.opacity)
            }

            Spacer(minLength: 0)

            if let _ = failureMessage {
                Btn(title: "Try another photo", kind: .primary, action: onRetry)
                    .padding(.horizontal, 24).padding(.bottom, 28)
            } else {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    @ViewBuilder private func outfitInset(height: CGFloat) -> some View {
        if let image = vm.capturedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: R.card))
        } else {
            Photo(height: height, tone: .warm, label: "user outfit · contained, editorial inset")
        }
    }

    @ViewBuilder private func outfitThumb() -> some View {
        if let image = vm.capturedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 68)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: R.input))
        } else {
            Photo(width: 56, height: 68, tone: .olive, radius: R.input)
        }
    }
}

// MARK: - S10 · Expanded "tell me more"

/// A quieter, fuller view of what we have. The MVP doesn't generate a long-form read
/// (the Stage 1/2 schema is the one-liner + tweak), so this shows the real one-liner
/// and tweak rather than fabricated paragraphs.
struct ExpandedView: View {
    @ObservedObject var vm: VibeCheckViewModel
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onDismiss) { Sym(name: "chevron-d", size: 18, color: C.inkSoft, stroke: 1.6).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("a longer read")
                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(vm.oneLiner)
                        .serif(22, color: C.ink, tracking: -0.1, lineHeight: 1.25)
                        .padding(.bottom, 18)

                    if let tweak = vm.tweakText {
                        MonoMarker("one tweak")
                            .padding(.top, 6)
                            .overlay(alignment: .top) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
                            .padding(.bottom, 10)
                        Text(tweak)
                            .serif(16, color: C.ink, lineHeight: 1.55)
                            .padding(.bottom, 18)
                    }

                    Text("That's the gist for now — a fuller read is on its way.")
                        .sans(13, color: C.inkMute, lineHeight: 1.5)

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
