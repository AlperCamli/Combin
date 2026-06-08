//  StyleVector.swift
//  Combin · Models
//
//  The style feature vector Gemini derives from the photo in Stage 2 (plan Step 1.7).
//  These are the 5 PLACEHOLDER axes for prototyping — do NOT rename or expand them
//  without the human's locked axis list + rubric. Scores are 0–100. This is internal
//  data: it is stored on the vibe-check and used later for similarity, but is NEVER
//  surfaced to the user (no scores/percentages in the UI — architectural invariant).

import Foundation

struct StyleVector: Codable, Equatable {
    var vibe: Int
    var formality: Int
    var colorfulness: Int
    var cohesion: Int
    var statementStrength: Int

    enum CodingKeys: String, CodingKey {
        case vibe, formality, colorfulness, cohesion
        case statementStrength = "statement_strength"  // Gemini + Supabase use snake_case
    }
}
