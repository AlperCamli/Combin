//  VibeCheck.swift
//  Combin · Models
//
//  A saved vibe-check row in Supabase plus the AI response shapes used by the
//  Edge Function stream.

import Foundation

// MARK: - Stored document

struct VibeCheck: Codable, Identifiable, Equatable {
    var id: String?
    var photoStoragePath: String
    var stage1Text: String
    var stage1Confidence: Double?
    var stage1Latency: Double?
    var tweakText: String?
    var styleVector: StyleVector?
    var garments: [Garment]?
    var createdAt: Date?
    var device: DeviceInfo?
    var stage2Latency: Double?

    struct DeviceInfo: Codable, Equatable {
        var os: String
        var model: String
    }

    enum CodingKeys: String, CodingKey {
        case id
        case photoStoragePath = "photo_path"
        case stage1Text = "stage1_text"
        case stage1Confidence = "stage1_confidence"
        case stage1Latency = "stage1_latency_ms"
        case tweakText = "tweak_text"
        case styleVector = "style_vector"
        case garments
        case createdAt = "created_at"
        case device
        case stage2Latency = "stage2_latency_ms"
    }
}

// MARK: - AI response shapes (Gemini structured output)

/// Stage 1 — the fast one-liner. `{ "vibe_check": "...", "confidence": 0.0–1.0 }`.
struct Stage1Response: Codable {
    var vibeCheck: String
    var confidence: Double

    enum CodingKeys: String, CodingKey {
        case vibeCheck = "vibe_check"
        case confidence
    }
}

/// Stage 2 — tweak + style vector + garments.
struct Stage2Response: Codable {
    var tweak: String?
    var styleVector: StyleVector
    var garments: [Garment]

    enum CodingKeys: String, CodingKey {
        case tweak
        case styleVector = "style_vector"
        case garments
    }
}
