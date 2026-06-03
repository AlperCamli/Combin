//  VibeCheckViewModel.swift
//  Combin · Features/VibeCheckResult
//
//  Drives the core loop end-to-end (plan Steps 1.2–1.8): compress → upload →
//  rate-limit → Stage 1 + Stage 2 in PARALLEL → display → save. The camera/looking/
//  result screens observe this object; transitions are driven by real async state,
//  not timers.
//
//  When Firebase isn't configured (no plist yet) or there's no uid, it runs a short
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

    @Published private(set) var vibeCheckId: String?

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
            if FirebaseConfig.isConfigured, let uid {
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
        vibeCheckId = nil
    }

    // MARK: - Real pipeline

    private func run(image: UIImage, uid: String) async {
        guard let data = image.combinJPEGData() else {
            fail(VibeVoice.genericTrouble); return
        }

        // Rate limit. During dev the function may be undeployed — don't block on that.
        do {
            let limit = try await service.checkRateLimit()
            if !limit.allowed { fail(VibeVoice.rateLimit); return }
        } catch {
            print("checkRateLimit unavailable, proceeding: \(error.localizedDescription)")
        }

        let upload: PhotoUploadService.Upload
        do {
            upload = try await uploader.upload(data: data, uid: uid)
        } catch {
            debugPrint("Combin · photo upload failed:", error)
            fail(VibeVoice.networkFailure); return
        }

        // Stage 1 and Stage 2 fire together the moment the upload lands.
        async let stage1 = service.runStage1(gsURI: upload.gsURI)
        async let stage2 = service.runStage2(gsURI: upload.gsURI)

        let s1: (text: String, confidence: Double, latency: Double)
        do {
            s1 = try await stage1
        } catch {
            _ = try? await stage2  // let it settle before we leave scope
            // A THROWN error is a technical failure (API disabled, App Check, network,
            // decode) — not the model reporting it can't see an outfit. The genuine
            // "no outfit" case comes back as a successful Stage 1 sentence. Surface the
            // real error so it's diagnosable, and show the connection-trouble copy.
            debugPrint("Combin · Stage 1 failed:", error)
            fail(VibeVoice.networkFailure)
            return
        }
        presentStage1(s1.text, confidence: s1.confidence)

        // Stage 2 is non-fatal: the one-liner already landed.
        var s2: (response: Stage2Response, latency: Double)?
        do { s2 = try await stage2 } catch {
            debugPrint("Combin · Stage 2 failed (non-fatal):", error)
        }
        if let s2 { presentStage2(s2.response) }

        persist(upload: upload, text: s1.text, stage1Latency: s1.latency,
                stage2: s2?.response, stage2Latency: s2?.latency, uid: uid)
    }

    private func persist(upload: PhotoUploadService.Upload,
                         text: String,
                         stage1Latency: Double,
                         stage2: Stage2Response?,
                         stage2Latency: Double?,
                         uid: String) {
        let device = VibeCheck.DeviceInfo(
            os: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            model: UIDevice.current.model
        )
        let doc = VibeCheck(
            photoStoragePath: upload.gsURI,
            stage1Text: text,
            stage1Latency: stage1Latency,
            tweakText: stage2?.tweak,
            styleVector: stage2?.styleVector,
            garments: stage2?.garments,
            createdAt: Date(),
            device: device,
            stage2Latency: stage2Latency
        )
        do {
            vibeCheckId = try service.save(doc, uid: uid)
        } catch {
            print("Saving vibe-check failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Demo (no backend)

    private func runDemo() async {
        try? await Task.sleep(nanoseconds: 1_400_000_000)
        guard !Task.isCancelled else { return }
        presentStage1("Three textures, one mood. That's the trick.", confidence: 0.82)
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        guard !Task.isCancelled else { return }
        presentStage2(Stage2Response(
            tweak: "Swap the belt for the olive one — it pulls the palette tighter without changing the silhouette.",
            styleVector: StyleVector(vibe: 72, formality: 60, colorfulness: 34, cohesion: 85, statementStrength: 40),
            garments: []
        ))
    }

    // MARK: - Presentation

    private func presentStage1(_ text: String, confidence: Double) {
        fullText = text
        self.confidence = confidence
        phase = .result
        startReveal()
    }

    private func presentStage2(_ response: Stage2Response) {
        styleVector = response.styleVector
        // A null/empty tweak means "you nailed it" — no card.
        if let tweak = response.tweak, !tweak.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
