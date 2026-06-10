//  VibeCheck.swift
//  Combin · Models
//
//  A saved vibe-check row in Supabase plus the AI response shapes used by the
//  Edge Function stream. Schema v2 carries the detailed outfit analysis
//  (summary, style tags, palette, photo quality) adopted from the rate-fit
//  prototype's data model — minus its scoring mechanics.

import Foundation

// MARK: - Stored document

struct VibeCheck: Codable, Identifiable, Equatable {
    var id: String?
    var photoStoragePath: String
    var thumbPath: String?
    var stage1Text: String
    var stage1Confidence: Double?
    var stage1Latency: Double?
    var tweakText: String?
    var summary: String?
    var styleVector: StyleVector?
    var styleTags: [String]?
    var occasionFit: [String: Int]?
    var palette: [ColorReading]?
    var photoQuality: PhotoQuality?
    var garments: [Garment]?
    var createdAt: Date?
    var device: DeviceInfo?
    var stage2Latency: Double?
    var schemaVersion: Int?

    /// Best path for grid thumbnails — falls back to the full photo.
    var gridImagePath: String { thumbPath ?? photoStoragePath }

    struct DeviceInfo: Codable, Equatable {
        var os: String
        var model: String
    }

    enum CodingKeys: String, CodingKey {
        case id
        case photoStoragePath = "photo_path"
        case thumbPath = "thumb_path"
        case stage1Text = "stage1_text"
        case stage1Confidence = "stage1_confidence"
        case stage1Latency = "stage1_latency_ms"
        case tweakText = "tweak_text"
        case summary
        case styleVector = "style_vector"
        case styleTags = "style_tags"
        case occasionFit = "occasion_fit"
        case palette
        case photoQuality = "photo_quality"
        case garments
        case createdAt = "created_at"
        case device
        case stage2Latency = "stage2_latency_ms"
        case schemaVersion = "schema_version"
    }
}

// MARK: - Shared analysis shapes

/// A color reading — used for the outfit palette and per-garment colors.
struct ColorReading: Codable, Equatable {
    var name: String?
    var hex: String?
    var percent: Double?
}

/// Capture diagnostics from Stage 2 — drives edge-case copy (low light,
/// no outfit visible), never shown as raw numbers.
struct PhotoQuality: Codable, Equatable {
    var personDetected: Bool?
    var faceVisible: Bool?
    var lighting: String?       // good | dim | harsh | mixed
    var blurriness: Double?
    var confidence: Double?
    var warnings: [String]?

    enum CodingKeys: String, CodingKey {
        case personDetected = "person_detected"
        case faceVisible = "face_visible"
        case lighting, blurriness, confidence, warnings
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

/// Stage 2 — tweak + longer read + style vector + garments.
struct Stage2Response: Codable {
    var tweak: String?
    var summary: String?
    var styleVector: StyleVector
    var garments: [Garment]

    enum CodingKeys: String, CodingKey {
        case tweak, summary
        case styleVector = "style_vector"
        case garments
    }
}
