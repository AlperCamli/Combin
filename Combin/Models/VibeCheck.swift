//  VibeCheck.swift
//  Combin · Models
//
//  The vibe-check document (plan Step 1.8) plus the two AI response shapes it's
//  assembled from. One document per outfit photo, at users/{uid}/vibeChecks/{id}.

import Foundation

// MARK: - Stored document

struct VibeCheck: Codable, Identifiable, Equatable {
    var id: String?                       // Firestore document id, set on read
    var photoStoragePath: String          // gs:// URI — also how the extractor finds this doc
    var stage1Text: String
    var stage1Latency: Double?
    var tweakText: String?
    var styleVector: StyleVector?
    var garments: [Garment]?              // read by extractGarments, then fanned into wardrobe
    var createdAt: Date?
    var device: DeviceInfo?
    var stage2Latency: Double?

    struct DeviceInfo: Codable, Equatable {
        var os: String
        var model: String
    }

    enum CodingKeys: String, CodingKey {
        case photoStoragePath, stage1Text, stage1Latency, tweakText
        case styleVector, garments, createdAt, device, stage2Latency
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
