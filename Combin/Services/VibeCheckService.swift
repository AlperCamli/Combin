//  VibeCheckService.swift
//  Combin · Services
//
//  The Gemini orchestrator (plan Steps 1.5 / 1.7 / 1.8 / 1.10). Talks to Firebase AI
//  Logic (Vertex AI backend), the rate-limit Cloud Function, and Firestore.
//
//  Invariants honored here:
//   • Model names + prompts come from Remote Config (never hardcoded).
//   • Every Gemini call uses structured output (responseSchema) → always valid JSON.
//   • Stage 1 is streamed for time-to-first-token.
//   • The photo is referenced by gs:// URI only; bytes never leave Cloud Storage
//     except transiently to Vertex AI.

import Foundation
import FirebaseAI
import FirebaseFirestore
import FirebaseFunctions
import FirebaseAnalytics

struct RateLimitResult {
    let allowed: Bool
    let reason: String?
    let limit: Int?
    let upgradeAvailable: Bool
}

enum VibeCheckError: Error { case emptyResponse, notConfigured }

final class VibeCheckService {

    private let functionsRegion = "europe-west1"
    private var ai: FirebaseAI { FirebaseAI.firebaseAI(backend: .vertexAI()) }
    private var db: Firestore { Firestore.firestore() }

    // MARK: - Rate limit (called before Stage 1)

    func checkRateLimit() async throws -> RateLimitResult {
        let functions = Functions.functions(region: functionsRegion)
        let response = try await functions.httpsCallable("checkRateLimit").call()
        let data = response.data as? [String: Any] ?? [:]
        return RateLimitResult(
            allowed: data["allowed"] as? Bool ?? true,
            reason: data["reason"] as? String,
            limit: data["limit"] as? Int,
            upgradeAvailable: data["upgradeAvailable"] as? Bool ?? false
        )
    }

    // MARK: - Stage 1 (the fast one-liner, streamed)

    func runStage1(gsURI: String) async throws -> (text: String, confidence: Double, latency: Double) {
        let model = ai.generativeModel(
            modelName: FirebaseConfig.string(FirebaseConfig.RCKey.stage1Model, fallback: "gemini-3.1-flash-lite"),
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: Self.stage1Schema
            )
        )
        let prompt = FirebaseConfig.string(FirebaseConfig.RCKey.stage1Prompt, fallback: PromptDefaults.stage1)
        let file = FileDataPart(uri: gsURI, mimeType: "image/jpeg")

        let start = Date()
        var full = ""
        // Stream to minimize time-to-first-token; we accumulate then parse the JSON.
        let stream = model.generateContentStream(prompt, file)
        for try await chunk in stream {
            if let text = chunk.text { full += text }
        }
        let latency = Date().timeIntervalSince(start)

        let parsed = try JSONDecoder().decode(Stage1Response.self, from: Data(full.utf8))
        Analytics.logEvent("vibecheck_stage1", parameters: [
            "latency_ms": Int(latency * 1000),
            "confidence": parsed.confidence,
        ])
        return (parsed.vibeCheck, parsed.confidence, latency)
    }

    // MARK: - Stage 2 (tweak + style vector + garments)

    func runStage2(gsURI: String) async throws -> (response: Stage2Response, latency: Double) {
        let model = ai.generativeModel(
            modelName: FirebaseConfig.string(FirebaseConfig.RCKey.stage2Model, fallback: "gemini-3.5-flash"),
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: Self.stage2Schema
            )
        )
        let prompt = FirebaseConfig.string(FirebaseConfig.RCKey.stage2Prompt, fallback: PromptDefaults.stage2)
        let file = FileDataPart(uri: gsURI, mimeType: "image/jpeg")

        let start = Date()
        let result = try await model.generateContent(prompt, file)
        let latency = Date().timeIntervalSince(start)

        guard let text = result.text, let data = text.data(using: .utf8) else {
            throw VibeCheckError.emptyResponse
        }
        let parsed = try JSONDecoder().decode(Stage2Response.self, from: data)
        Analytics.logEvent("vibecheck_stage2", parameters: [
            "latency_ms": Int(latency * 1000),
            "garments": parsed.garments.count,
        ])
        return (parsed, latency)
    }

    // MARK: - Save (Step 1.8)

    @discardableResult
    func save(_ vibeCheck: VibeCheck, uid: String) throws -> String {
        let ref = db.collection("users/\(uid)/vibeChecks").document()
        // Offline persistence: this completes locally immediately and syncs later.
        try ref.setData(from: vibeCheck)
        return ref.documentID
    }

    // MARK: - Structured-output schemas

    static let stage1Schema = Schema.object(properties: [
        "vibe_check": .string(),
        "confidence": .double(),
    ])

    static let stage2Schema = Schema.object(
        properties: [
            "tweak": .string(),
            "style_vector": .object(properties: [
                "vibe": .integer(),
                "formality": .integer(),
                "colorfulness": .integer(),
                "cohesion": .integer(),
                "statement_strength": .integer(),
            ]),
            "garments": .array(items: .object(properties: [
                "category": .string(),
                "type": .string(),
                "color": .string(),
                "confidence": .double(),
            ])),
        ],
        optionalProperties: ["tweak"]
    )
}
