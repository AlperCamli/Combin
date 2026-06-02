//  VibeVoice.swift
//  Combin · Features/VibeCheckResult
//
//  User-facing strings for the vibe-check loop, lifted verbatim from the brief's
//  "Voice and copy guide". Centralized so the voice stays consistent and reviewable.
//  Warm, specific, never preachy. No school-test framing, no body language.

import Foundation

enum VibeVoice {

    /// Cycled on the "Thinking…" screen (~2.5s each).
    static let loadingPhrases = [
        "looking closely…",
        "reading the outfit…",
        "thinking it over…",
        "checking the proportions…",
        "finding the right words…",
    ]

    // Edge cases.
    static let noOutfit       = "I can't quite see the outfit — want to try another angle?"
    static let lowLight       = "Hard to read in this light, but here's what I caught."
    static let networkFailure = "Lost the connection for a sec. Pull down to try again."
    static let rateLimit      = "You've had a lot of vibe-checks today. Try again tomorrow."
    static let zeroGarments   = "This one was a little tricky to read — want to try another photo? " +
                                "Sometimes a different angle or better light makes all the difference."
    static let genericTrouble = "Something got in the way of reading this one — want to try again?"
}
