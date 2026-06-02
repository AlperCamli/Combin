//  CombinApp.swift
//  Combin — a warm, fast, fashion-literate read on what you're wearing.
//
//  Tier 1: Journey 1 (onboarding) + Journey 2 (daily mirror check), built on a
//  reusable design-system foundation. SwiftUI, iPhone, portrait.

import SwiftUI

@main
struct CombinApp: App {
    @StateObject private var auth: AuthService

    init() {
        // Belt-and-suspenders: fonts are also declared in Info.plist (UIAppFonts).
        F.registerBundledFonts()
        // App Check + Firebase + Remote Config. No-ops (with a warning) until the
        // GoogleService-Info.plist ships, so the UI still runs before the backend.
        FirebaseConfig.configure()
        // Constructed after configure() so it sees the configured state.
        _auth = StateObject(wrappedValue: AuthService())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
        }
    }
}
