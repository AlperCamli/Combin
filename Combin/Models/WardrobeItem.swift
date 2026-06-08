//  WardrobeItem.swift
//  Combin · Models
//
//  A single garment in the user's wardrobe. Written by the Supabase Edge Function
//  from a vibe-check's `garments` array.

import Foundation

/// A garment as Gemini returns it inside the Stage 2 structured output.
struct Garment: Codable, Equatable {
    var category: String?
    var type: String?
    var color: String?
    var confidence: Double?
    var attributes: [String: String]?
}

struct WardrobeItem: Codable, Identifiable, Equatable {
    var id: String?
    var sourceVibeCheckId: String?
    var sourcePhotoStoragePath: String?
    var category: String?
    var type: String?
    var color: String?
    var confidence: Double?
    var attributes: [String: String]?
    var status: String?                   // "active"
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case sourceVibeCheckId = "source_vibe_check_id"
        case sourcePhotoStoragePath = "source_photo_path"
        case category, type, color, confidence, attributes, status
        case createdAt = "created_at"
    }
}
