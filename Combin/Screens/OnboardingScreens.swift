//  OnboardingScreens.swift
//  Combin · Journey 1 — Onboarding
//
//  First-launch through first vibe-check. The trust screen carries more weight
//  than any other screen here. Ported from screens-onboarding.jsx and
//  screens-daily.jsx (S6 first result), then wired to the real capture + vibe-check
//  loop (Phase 2).

import SwiftUI
import AVFoundation
import Photos
import UIKit

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

    @State private var expanded = false

    private let items: [(icon: String, text: String)] = [
        ("lock",   "Your photos stay on your device when possible."),
        ("shield", "What we send to the AI is encrypted."),
        ("trash",  "Delete any photo, any time."),
        ("no-ad",  "We never sell your data, and there are no ads."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        MonoMarker("⟶ About your photos", tracking: 1.2)
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

                    // "Tell me more" expands inline — never navigates away.
                    if expanded {
                        Text("In plain terms: when you ask for a vibe-check, your photo goes to Google's Gemini to read the outfit — over an encrypted connection, only for that read. It's not sold, not used for ads, and not used to train anyone's model. You can delete any photo, or all of them, whenever you like.")
                            .sans(13.5, color: C.inkSoft, lineHeight: 1.55)
                            .padding(.horizontal, 28)
                            .padding(.top, 24)
                            .transition(.opacity)
                    }
                }
            }

            VStack(spacing: 8) {
                Btn(title: "Got it", kind: .primary, action: onGotIt)
                Btn(title: expanded ? "Show less" : "Tell me more", kind: .ghost) {
                    withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - S3 · Taste calibration  (DEFERRED — not wired into the MVP flow)

/// Kept from the Tier-1 design but intentionally skipped in onboarding: taste
/// calibration depends on the final style-vector axes, which aren't locked yet
/// (plan Steps 1.7 / 2.3). Re-insert into `OnboardingFlow` once the axes are set.
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

    @State private var requesting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                MonoMarker("Almost there", tracking: 1.2).padding(.bottom, 14)
                Text("To read your outfit,\nwe need to see it.")
                    .serif(26, color: C.ink, tracking: -0.2, lineHeight: 1.15)
                Text("Camera for new photos, Photos for ones you already took. Optional — the app still works, and we'll ask about notifications later, once you're in the habit.")
                    .sans(13.5, color: C.inkSoft, lineHeight: 1.5)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 28).padding(.top, 32)

            VStack(spacing: 12) {
                permissionRow(icon: "camera", title: "Camera",
                              detail: "For a quick photo of what you're wearing.")
                permissionRow(icon: "gallery-sm", title: "Photos",
                              detail: "To use one you've already taken.")
            }
            .padding(.horizontal, 24).padding(.top, 28)

            Spacer(minLength: 0)

            Btn(title: "Allow access", kind: .primary, action: requestAccess)
                .padding(.horizontal, 28)
            Btn(title: "Maybe later", kind: .ghost, action: onContinue)
                .padding(.horizontal, 28).padding(.top, 8).padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
        .disabled(requesting)
    }

    private func permissionRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Sym(name: icon, size: 18, color: C.ink, stroke: 1.5).padding(.top, 2)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(F.sans(15, .medium)).foregroundStyle(C.ink)
                Text(detail).sans(13, color: C.inkSoft, lineHeight: 1.45)
            }
            Spacer(minLength: 0)
        }
        .padding(.init(top: 16, leading: 16, bottom: 16, trailing: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .hairline(C.paperLine, radius: R.card)
    }

    /// Standard iOS prompts. Either outcome continues — first-capture handles denial.
    private func requestAccess() {
        requesting = true
        Task {
            _ = await AVCaptureDevice.requestAccess(for: .video)
            await requestPhotoLibrary()
            await MainActor.run {
                requesting = false
                onContinue()
            }
        }
    }

    private func requestPhotoLibrary() async {
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in cont.resume() }
        }
    }
}

// MARK: - S5 · First photo capture

struct FirstCaptureView: View {
    var onCapture: (UIImage) -> Void

    @StateObject private var camera = CameraController()
    @State private var showPicker = false
    @State private var capturing = false

    private var liveCamera: Bool { camera.isAuthorized && camera.isAvailable }

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if liveCamera {
                    CameraPreview(session: camera.session).ignoresSafeArea()
                } else {
                    Photo(height: nil, tone: .char, label: "camera unavailable here · use a recent photo",
                          radius: 0, dark: true)
                        .ignoresSafeArea()
                }
            }
            .overlay(
                LinearGradient(stops: [
                    .init(color: .black.opacity(0.45), location: 0.0),
                    .init(color: .black.opacity(0.05), location: 0.30),
                    .init(color: .black.opacity(0.05), location: 0.60),
                    .init(color: .black.opacity(0.70), location: 1.0),
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            )
            .overlay(FrameGuide())

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    MonoMarker("First read", color: Overlay.paperWhite.opacity(0.55), tracking: 1.2)
                        .padding(.bottom, 10)
                    Text("Show me what you're\nwearing today.")
                        .serif(24, color: Overlay.paperWhite.opacity(0.92), tracking: -0.1, lineHeight: 1.18)
                    Text("Don't worry — someone else can take the photo for you. Just make sure the outfit's visible.")
                        .sans(13, color: Overlay.paperWhite.opacity(0.65), lineHeight: 1.45)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28).padding(.top, 20)

                Spacer(minLength: 0)

                VStack(spacing: 10) {
                    Button(action: capture) {
                        ZStack {
                            Text("Take a photo")
                                .font(F.sans(15, .medium)).foregroundStyle(C.ink)
                                .opacity(capturing ? 0 : 1)
                            if capturing { ProgressView().tint(C.ink) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14).padding(.horizontal, 20)
                        .background(C.paper)
                        .clipShape(RoundedRectangle(cornerRadius: R.card))
                        .opacity(liveCamera ? 1 : 0.4)
                    }
                    .buttonStyle(.plain)
                    .disabled(!liveCamera || capturing)

                    Button { showPicker = true } label: {
                        Text("or pick one from your photos")
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
        .task {
            await camera.configure()
            camera.start()
        }
        .onDisappear { camera.stop() }
        .sheet(isPresented: $showPicker) {
            PhotoPicker(onPick: { onCapture($0) }).ignoresSafeArea()
        }
    }

    private func capture() {
        guard liveCamera, !capturing else { return }
        capturing = true
        Task {
            defer { capturing = false }
            if let image = try? await camera.capture() { onCapture(image) }
        }
    }
}

// MARK: - S6 · First vibe-check result

/// The first vibe-check result. Same hero one-liner as the daily flow, but it ends
/// on the onboarding handoff — gated on whether garments were actually extracted
/// (plan Steps 2.3 / 2.4). Driven entirely by the `saved` event the backend streams
/// through the shared VibeCheckViewModel; no wardrobe polling.
struct FirstResultView: View {
    @ObservedObject var vm: VibeCheckViewModel
    var onShowCloset: () -> Void
    var onSkip: () -> Void
    var onRetry: () -> Void

    private enum Extraction { case checking, found, none }

    private var extraction: Extraction {
        guard let count = vm.garmentsWritten else { return .checking }
        return count > 0 ? .found : .none
    }

    private var failureMessage: String? {
        if case .failed(let message) = vm.phase { return message }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Color.clear.frame(width: 36, height: 36)
                Spacer()
                Sym(name: "lock", size: 14, color: C.inkMute, stroke: 1.5)
                    .frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            outfitInset(height: 210)
                .padding(.horizontal, 28).padding(.top, 8)

            Text(failureMessage ?? vm.revealedText)
                .serif(26, color: C.ink, tracking: -0.15, lineHeight: 1.22)
                .animation(.easeOut(duration: 0.15), value: vm.revealedText)
                .padding(.horizontal, 28).padding(.top, 32)

            if failureMessage == nil, vm.tweakReady, let tweak = vm.tweakText {
                VStack(alignment: .leading, spacing: 8) {
                    MonoMarker("one tweak", color: C.accent)
                    Text(tweak)
                        .sans(13.5, color: C.inkSoft, lineHeight: 1.55)
                        .padding(.leading, 12)
                        .overlay(alignment: .leading) { Rectangle().fill(C.paperLine).frame(width: 1) }
                }
                .padding(.horizontal, 28).padding(.top, 26)
                .transition(.opacity)
            }

            Spacer(minLength: 0)

            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
        .animation(.easeInOut(duration: 0.3), value: vm.garmentsWritten)
    }

    // MARK: Footer (handoff / retry / failure)

    @ViewBuilder private var footer: some View {
        if failureMessage != nil {
            Btn(title: "Try another photo", kind: .primary, action: onRetry)
                .padding(.horizontal, 24).padding(.bottom, 28)
        } else {
            switch extraction {
            case .checking:
                Text("Adding what I can see to your closet…")
                    .sans(13, color: C.inkMute)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 28).padding(.bottom, 28)

            case .found:
                (Text("I just learned a few pieces of your closet. ").foregroundStyle(C.ink)
                 + Text("Want to see?").foregroundStyle(C.accent))
                    .font(F.serif(16))
                    .tracking(-0.05)
                    .padding(.horizontal, 28).padding(.top, 4)
                Btn(title: "Show me my closet", kind: .primary, action: onShowCloset)
                    .padding(.horizontal, 24).padding(.top, 14).padding(.bottom, 28)

            case .none:
                VStack(alignment: .leading, spacing: 14) {
                    Text("This one was a little tricky to read — want to try another photo? Sometimes a different angle or better light makes all the difference.")
                        .sans(14, color: C.ink, lineHeight: 1.5)
                    HStack(spacing: 10) {
                        Btn(title: "Try another photo", kind: .primary, action: onRetry)
                        Btn(title: "Skip for now", kind: .outline, action: onSkip)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 8).padding(.bottom, 28)
            }
        }
    }

    @ViewBuilder private func outfitInset(height: CGFloat) -> some View {
        if let image = vm.capturedImage {
            Image(uiImage: image)
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity).frame(height: height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: R.card))
        } else {
            Photo(height: height, tone: .ecru, label: "first photo · editorial inset")
        }
    }
}
