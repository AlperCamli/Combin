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
}
