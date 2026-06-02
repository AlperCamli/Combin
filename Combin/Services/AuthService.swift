//  AuthService.swift
//  Combin · Services
//
//  Anonymous-first auth (plan Step 0.6). On cold start, if there's no current user,
//  sign in anonymously. The uid is published for the rest of the app. The
//  "Setting things up…" state shows only while the very first sign-in is in flight;
//  later launches resume the persisted anonymous session instantly.

import Foundation
import FirebaseAuth

@MainActor
final class AuthService: ObservableObject {

    enum State: Equatable {
        case loading              // very first launch — anonymous sign-in in flight
        case signedIn(String)     // uid available
        case unavailable          // Firebase not configured (no plist) — UI-only mode
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var uid: String?

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        guard FirebaseConfig.isConfigured else {
            // No backend yet — let the app run as the design-system UI.
            state = .unavailable
            return
        }

        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            // The listener fires off-actor; hop to the main actor to mutate state.
            Task { @MainActor in self?.handleAuthChange(user) }
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    private func handleAuthChange(_ user: User?) {
        if let user {
            uid = user.uid
            state = .signedIn(user.uid)
            print("Combin auth: \(user.isAnonymous ? "anonymous " : "")uid \(user.uid)")
        } else {
            uid = nil
            Task { await signInAnonymously() }
        }
    }

    private func signInAnonymously() async {
        do {
            _ = try await Auth.auth().signInAnonymously()
            // Success path is handled by the state listener.
        } catch {
            print("Combin auth: anonymous sign-in failed — \(error.localizedDescription)")
            // Stay in .loading; the listener will retry on next launch / connectivity.
        }
    }
}
