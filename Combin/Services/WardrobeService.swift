//  WardrobeService.swift
//  Combin · Services
//
//  Reads the user's wardrobe (written server-side by extractGarments). Minimal for
//  Phase 1: a recent-items fetch plus the onboarding "did extraction succeed?" poll
//  (plan Step 2.7 Option A — used in Phase 2, available now).

import Foundation
import FirebaseFirestore

final class WardrobeService {

    private var db: Firestore { Firestore.firestore() }

    /// Most-recent wardrobe items for the user.
    func recentItems(uid: String, limit: Int = 60) async throws -> [WardrobeItem] {
        let snapshot = try await db.collection("users/\(uid)/wardrobe")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap { decode($0) }
    }

    /// Poll for items extracted from a specific vibe-check, up to `timeout` seconds.
    /// Returns true as soon as any item appears. Used by onboarding to decide between
    /// the "see your closet" handoff and the zero-extraction retry card.
    func awaitExtraction(uid: String, vibeCheckId: String, timeout: TimeInterval = 5) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let count = try? await db.collection("users/\(uid)/wardrobe")
                .whereField("sourceVibeCheckId", isEqualTo: vibeCheckId)
                .limit(to: 1)
                .getDocuments()
                .count
            if let count, count > 0 { return true }
            try? await Task.sleep(nanoseconds: 700_000_000)
        }
        return false
    }

    private func decode(_ doc: QueryDocumentSnapshot) -> WardrobeItem? {
        var item = try? doc.data(as: WardrobeItem.self)
        item?.id = doc.documentID
        return item
    }
}
