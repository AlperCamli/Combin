//  VibeCheckViewModel.swift
//  Combin · Features/VibeCheckResult
//
//  Drives the core loop end-to-end: compress → upload to Supabase Storage →
//  stream the backend-owned AI/persistence pipeline.
//
//  When Supabase isn't configured or there's no uid, it runs a short
//  canned "demo" so the UI is still exercisable on a machine without the backend.

import SwiftUI
import UIKit

@MainActor
final class VibeCheckViewModel: ObservableObject {

    enum Phase: Equatable {
        case idle           // camera open, nothing captured
        case processing     // "Thinking…" — Stage 1 in flight
        case result         // one-liner is in; tweak may still be loading
        case failed(String) // friendly copy explaining what happened
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var capturedImage: UIImage?

    // Stage 1
    @Published private(set) var revealedText = ""     // grows word-by-word
    @Published private(set) var confidence: Double = 1

    // Stage 2
    @Published private(set) var tweakText: String?
    @Published private(set) var tweakReady = false
    @Published private(set) var styleVector: StyleVector?
    /// The longer read shown by the expanded "tell me more" view.
    @Published private(set) var summary: String?

    @Published private(set) var vibeCheckId: String?

    /// From the `saved` SSE event — how many garments Stage 2 fanned out into the
    /// wardrobe. `nil` until persistence completes; drives the onboarding handoff
    /// (plan Step 2.3) without polling the wardrobe table.
    @Published private(set) var garmentsWritten: Int?

    /// The full one-liner (used by the expanded read, which may open before the
    /// word-by-word reveal has finished).
    var oneLiner: String { fullText }

    private let uploader = PhotoUploadService()
    private let service = VibeCheckService()
    private var fullText = ""
    private var revealTask: Task<Void, Never>?
    private var runTask: Task<Void, Never>?

    // MARK: - Entry

    func start(with image: UIImage, uid: String?) {
        reset()
        capturedImage = image
        phase = .processing

        runTask = Task { [weak self] in
            guard let self else { return }
            if SupabaseConfig.isConfigured, let uid {
                await self.run(image: image, uid: uid)
            } else {
                await self.runDemo()
            }
        }
    }

    func reset() {
        runTask?.cancel()
        revealTask?.cancel()
        phase = .idle
        capturedImage = nil
        revealedText = ""
        fullText = ""
        confidence = 1
        tweakText = nil
        tweakReady = false
        styleVector = nil
        summary = nil
        vibeCheckId = nil
        garmentsWritten = nil
    }

    // MARK: - Real pipeline

    private func run(image: UIImage, uid: String) async {
        guard let data = image.combinJPEGData() else {
            fail(VibeVoice.genericTrouble); return
        }

        let upload: PhotoUploadService.Upload
        do {
            let thumbData = image.combinJPEGData(maxEdge: 512, quality: 0.6)
            upload = try await uploader.upload(data: data, thumbData: thumbData, uid: uid)
        } catch {
            debugPrint("Combin · photo upload failed:", error)
            fail(VibeVoice.networkFailure); return
        }

        let device = VibeCheck.DeviceInfo(
            os: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            model: UIDevice.current.model
        )
        var receivedStage1 = false
        do {
            for try await event in service.process(photoPath: upload.photoPath, thumbPath: upload.thumbPath, device: device) {
                switch event {
                case .stage1(let stage1):
                    receivedStage1 = true
                    presentStage1(stage1.text, confidence: stage1.confidence)
                case .stage2(let stage2):
                    presentStage2(tweak: stage2.tweakText, summary: stage2.summary, styleVector: stage2.styleVector)
                case .saved(let saved):
                    vibeCheckId = saved.vibeCheckId
                    garmentsWritten = saved.garmentsWritten
                }
            }
        } catch {
            debugPrint("Combin · vibe-check stream failed:", error)
            if !receivedStage1 {
                if case VibeCheckError.rateLimited = error {
                    fail(VibeVoice.rateLimit)
                } else {
                    fail(VibeVoice.networkFailure)
                }
            } else if garmentsWritten == nil {
                // Stage 1 landed but the save never confirmed — resolve the
                // handoff as "nothing extracted" so onboarding doesn't hang.
                garmentsWritten = 0
            }
            return
        }

        if !receivedStage1 {
            fail(VibeVoice.networkFailure)
        } else if garmentsWritten == nil {
            garmentsWritten = 0
        }
    }

    // MARK: - Demo (no backend)

    private func runDemo() async {
        try? await Task.sleep(nanoseconds: 1_400_000_000)
        guard !Task.isCancelled else { return }
        presentStage1("Three textures, one mood. That's the trick.", confidence: 0.82)
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        guard !Task.isCancelled else { return }
        let demo = Stage2Response(
            tweak: "Swap the belt for the olive one — it pulls the palette tighter without changing the silhouette.",
            summary: "The cream layer is doing the anchoring here: it warms the frame and lets the darker pieces read as a choice, not a default. The palette stays in one conversation, and the proportions sit easy.",
            styleVector: StyleVector(formality: 60, trendiness: 45, boldness: 38, colorfulness: 34, cohesion: 85),
            garments: []
        )
        presentStage2(tweak: demo.tweak, summary: demo.summary, styleVector: demo.styleVector)
        garmentsWritten = 1  // demo: show the onboarding closet handoff
    }

    // MARK: - Presentation

    private func presentStage1(_ text: String, confidence: Double) {
        fullText = text
        self.confidence = confidence
        phase = .result
        startReveal()
    }

    private func presentStage2(tweak: String?, summary: String?, styleVector: StyleVector) {
        self.styleVector = styleVector
        self.summary = summary?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? summary : nil
        // A null/empty tweak means "you nailed it" — no card.
        if let tweak, !tweak.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tweakText = tweak
        } else {
            tweakText = nil
        }
        withAnimation(.easeInOut(duration: 0.45)) { tweakReady = true }
    }

    /// Reveal the one-liner word-by-word — a calm, low-stutter alternative to
    /// streaming raw JSON to the screen.
    private func startReveal() {
        revealTask?.cancel()
        revealedText = ""
        let words = fullText.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
        revealTask = Task { @MainActor [weak self] in
            var assembled = ""
            for (i, word) in words.enumerated() {
                if Task.isCancelled { return }
                assembled += (i == 0 ? "" : " ") + word
                self?.revealedText = assembled
                try? await Task.sleep(nanoseconds: 65_000_000)
            }
        }
    }

    private func fail(_ message: String) {
        revealTask?.cancel()
        phase = .failed(message)
    }
}
