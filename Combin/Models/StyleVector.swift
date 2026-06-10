//  StyleVector.swift
//  Combin · Models
//
//  The style feature vector Gemini derives from the photo in Stage 2.
//  Schema v2: twelve axes adopted from the user's rate-fit prototype
//  (`outfit_analysis`), scored 0–100. This is internal data: it is stored on the
//  vibe-check and used later for similarity, but is NEVER surfaced to the user
//  (no scores/percentages in the UI — architectural invariant). Fields are
//  optional so rows saved under the older 5-axis schema still decode.

import Foundation

struct StyleVector: Codable, Equatable {
    var formality: Int?
    var trendiness: Int?
    var boldness: Int?
    var colorfulness: Int?
    var cohesion: Int?
    var layeringComplexity: Int?
    var accessoryDensity: Int?
    var silhouetteRelaxedVsTailored: Int?
    var seasonalityWarmth: Int?
    var contrast: Int?
    var monochromeIndex: Int?
    var neutralRatio: Int?

    enum CodingKeys: String, CodingKey {
        case formality, trendiness, boldness, colorfulness, cohesion, contrast
        case layeringComplexity = "layering_complexity"
        case accessoryDensity = "accessory_density"
        case silhouetteRelaxedVsTailored = "silhouette_relaxed_vs_tailored"
        case seasonalityWarmth = "seasonality_warmth"
        case monochromeIndex = "monochrome_index"
        case neutralRatio = "neutral_ratio"
    }
}
