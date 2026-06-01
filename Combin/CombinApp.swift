//  CombinApp.swift
//  Combin — a warm, fast, fashion-literate read on what you're wearing.
//
//  Tier 1: Journey 1 (onboarding) + Journey 2 (daily mirror check), built on a
//  reusable design-system foundation. SwiftUI, iPhone, portrait.

import SwiftUI

@main
struct CombinApp: App {
    init() {
        // Belt-and-suspenders: fonts are also declared in Info.plist (UIAppFonts).
        F.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
