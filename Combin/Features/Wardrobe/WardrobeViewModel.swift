//  WardrobeViewModel.swift
//  Combin · Features/Wardrobe
//
//  Loads the user's recent vibe-checks for the Wardrobe "Looks" grid (plan Step 3.2)
//  and the extracted garments behind the "Items" toggle (plan Step 3.3).

import SwiftUI

@MainActor
final class WardrobeViewModel: ObservableObject {
    @Published private(set) var vibeChecks: [VibeCheck] = []
    @Published private(set) var items: [WardrobeItem] = []
    @Published private(set) var loaded = false

    private let service = WardrobeService()

    func load(uid: String?) async {
        guard SupabaseConfig.isConfigured, let uid else {
            loaded = true
            return
        }
        async let checksFetch = service.recentVibeChecks(uid: uid)
        async let itemsFetch = service.recentItems(uid: uid)
        do {
            vibeChecks = try await checksFetch
        } catch {
            debugPrint("Combin · wardrobe looks load failed:", error)
        }
        do {
            items = try await itemsFetch
        } catch {
            debugPrint("Combin · wardrobe items load failed:", error)
        }
        loaded = true
    }
}
