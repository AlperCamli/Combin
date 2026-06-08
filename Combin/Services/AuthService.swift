//  AuthService.swift
//  Combin · Services
//
//  Anonymous-first auth via Supabase. On cold start, if no persisted session is
//  available, create an anonymous user and publish its uid for the rest of the app.

import Foundation
import Supabase

@MainActor
final class AuthService: ObservableObject {

    enum State: Equatable {
        case loading
        case signedIn(String)
        case unavailable
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var uid: String?

    init() {
        guard SupabaseConfig.isConfigured else {
            state = .unavailable
            return
        }

        if let user = SupabaseConfig.requiredClient.auth.currentUser {
            let id = user.id.uuidString.lowercased()
            uid = id
            state = .signedIn(id)
            print("Combin auth: restored Supabase uid \(id)")
        } else {
            Task { await signInAnonymously() }
        }
    }

    private func signInAnonymously() async {
        do {
            let session = try await SupabaseConfig.requiredClient.auth.signInAnonymously()
            let id = session.user.id.uuidString.lowercased()
            uid = id
            state = .signedIn(id)
            print("Combin auth: anonymous Supabase uid \(id)")
        } catch {
            print("Combin auth: anonymous sign-in failed - \(error.localizedDescription)")
        }
    }
}
