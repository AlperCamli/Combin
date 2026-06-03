//  WardrobeViewModel.swift
//  Combin · Features/Wardrobe
//
//  Loads the user's recent vibe-checks for the Wardrobe "Looks" grid (plan Step 3.2,
//  pulled forward so the onboarding handoff lands on real photos). Items mode stays
//  out of scope for the MVP.

import SwiftUI

@MainActor
final class WardrobeViewModel: ObservableObject {
    @Published private(set) var vibeChecks: [VibeCheck] = []
    @Published private(set) var loaded = false

    private let service = WardrobeService()

    func load(uid: String?) async {
        guard FirebaseConfig.isConfigured, let uid else {
            loaded = true
            return
        }
        do {
            vibeChecks = try await service.recentVibeChecks(uid: uid)
        } catch {
            debugPrint("Combin · wardrobe load failed:", error)
        }
        loaded = true
    }
}
