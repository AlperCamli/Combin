//  WardrobeItem.swift
//  Combin · Models
//
//  A single garment in the user's wardrobe. Written by the `extractGarments` Cloud
//  Function (plan Step 1.9) from a vibe-check's `garments` array — no per-item crop;
//  each item references the full source photo (`sourcePhotoStoragePath`).

import Foundation

/// A garment as Gemini returns it inside the Stage 2 structured output.
struct Garment: Codable, Equatable {
    var category: String?
    var type: String?
    var color: String?
    var confidence: Double?
    var attributes: [String: String]?
}

/// A wardrobe document at users/{uid}/wardrobe/{itemId}.
struct WardrobeItem: Codable, Identifiable, Equatable {
    var id: String?                       // Firestore document id, set on read
    var sourceVibeCheckId: String?
    var sourcePhotoStoragePath: String?
    var category: String?
    var type: String?
    var color: String?
    var status: String?                   // "active"
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case sourceVibeCheckId, sourcePhotoStoragePath
        case category, type, color, status, createdAt
        // `id` is the document id, supplied at read time — not a stored field.
    }
}
