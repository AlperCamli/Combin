//  WardrobeItem.swift
//  Combin · Models
//
//  A single garment in the user's wardrobe. Written by the Supabase Edge Function
//  from a vibe-check's `garments` array. Schema v2 adds the per-item detail from
//  the rate-fit prototype (`outfit_items` + `outfit_item_colors`): subtype,
//  pattern, material guess, fit, and a color breakdown — no item scores.

import Foundation

/// A garment as Gemini returns it inside the Stage 2 structured output.
struct Garment: Codable, Equatable {
    var slot: String?
    var category: String?
    var type: String?
    var subtype: String?
    var color: String?
    var colors: [ColorReading]?
    var pattern: String?
    var materialGuess: String?
    var fit: String?
    var confidence: Double?
    var comment: String?

    enum CodingKeys: String, CodingKey {
        case slot, category, type, subtype, color, colors, pattern, fit, confidence, comment
        case materialGuess = "material_guess"
    }
}

struct WardrobeItem: Codable, Identifiable, Equatable {
    var id: String?
    var sourceVibeCheckId: String?
    var sourcePhotoStoragePath: String?
    var category: String?
    var type: String?
    var subtype: String?
    var color: String?
    var colors: [ColorReading]?
    var pattern: String?
    var materialGuess: String?
    var fit: String?
    var confidence: Double?
    var comment: String?
    var status: String?                   // "active"
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case sourceVibeCheckId = "source_vibe_check_id"
        case sourcePhotoStoragePath = "source_photo_path"
        case category, type, subtype, color, colors, pattern, fit, confidence, comment, status
        case materialGuess = "material_guess"
        case createdAt = "created_at"
    }
}
