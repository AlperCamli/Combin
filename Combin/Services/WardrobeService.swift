//  WardrobeService.swift
//  Combin · Services
//
//  Reads saved looks and extracted wardrobe items from Supabase Postgres.

import Foundation

final class WardrobeService {

    func recentItems(uid: String, limit: Int = 60) async throws -> [WardrobeItem] {
        try await SupabaseConfig.requiredClient
            .from("wardrobe_items")
            .select()
            .eq("user_id", value: uid)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func recentVibeChecks(uid: String, limit: Int = 60) async throws -> [VibeCheck] {
        try await SupabaseConfig.requiredClient
            .from("vibe_checks")
            .select()
            .eq("user_id", value: uid)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func awaitExtraction(uid: String, vibeCheckId: String, timeout: TimeInterval = 5) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let items: [WardrobeItem]? = try? await SupabaseConfig.requiredClient
                .from("wardrobe_items")
                .select("id")
                .eq("user_id", value: uid)
                .eq("source_vibe_check_id", value: vibeCheckId)
                .limit(1)
                .execute()
                .value
            if let items, !items.isEmpty { return true }
            try? await Task.sleep(nanoseconds: 700_000_000)
        }
        return false
    }
}
