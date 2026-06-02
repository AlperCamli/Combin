//  AppFlow.swift
//  Combin
//
//  Wires the Tier-1 screens into a running app. The default state of the app is
//  camera-open (not a home feed), per the brief: onboarding runs once, then the
//  camera flow is presented over the tab world.

import SwiftUI

// MARK: - App state

@MainActor
final class AppState: ObservableObject {
    private let key = "combin.onboarded"
    @Published var onboarded: Bool

    init() {
        onboarded = UserDefaults.standard.bool(forKey: key)
    }
    func completeOnboarding() {
        onboarded = true
        UserDefaults.standard.set(true, forKey: key)
    }
}

// MARK: - Root

struct RootView: View {
    @StateObject private var app = AppState()

    var body: some View {
        ZStack {
            if app.onboarded {
                MainShell()
                    .transition(.opacity)
            } else {
                OnboardingFlow(onFinish: { app.completeOnboarding() })
                    .transition(.opacity)
            }
        }
        .environmentObject(app)
        .animation(.easeInOut(duration: 0.4), value: app.onboarded)
    }
}

// MARK: - Journey 1 flow

struct OnboardingFlow: View {
    var onFinish: () -> Void
    private enum Step { case welcome, trust, taste, permissions, capture, looking, result }
    @State private var step: Step = .welcome

    var body: some View {
        ZStack {
            switch step {
            case .welcome:
                WelcomeView(onContinue: { go(.trust) }).transition(.opacity)
            case .trust:
                TrustView(onGotIt: { go(.taste) }, onMore: { go(.taste) }).transition(.opacity)
            case .taste:
                TasteView(onContinue: { go(.permissions) }).transition(.opacity)
            case .permissions:
                PermissionsView(onContinue: { go(.capture) }).transition(.opacity)
            case .capture:
                FirstCaptureView(onCapture: { go(.looking) }).transition(.opacity)
            case .looking:
                LookingView()
                    .transition(.opacity)
                    .task {
                        try? await Task.sleep(nanoseconds: 1_900_000_000)
                        go(.result)
                    }
            case .result:
                FirstResultView(onShowCloset: onFinish).transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.42), value: step)
    }

    private func go(_ s: Step) { withAnimation(.easeInOut(duration: 0.42)) { step = s } }
}

// MARK: - Main shell (tab world + camera-first cover)

struct MainShell: View {
    @State private var tab = "wardrobe"
    @State private var cameraPresented = true   // camera-first on launch

    var body: some View {
        TabWorld(tab: $tab, onCapture: { cameraPresented = true })
            .fullScreenCover(isPresented: $cameraPresented) {
                CameraFlow(
                    onClose: { cameraPresented = false },
                    onGoWardrobe: { tab = "wardrobe"; cameraPresented = false }
                )
            }
    }
}

/// The non-camera tabs. Each tab is its own self-contained journey flow that
/// embeds the reusable `TabBar` on its root screen and drives its own internal
/// navigation (details, sheets). Switching tabs swaps the whole flow.
private struct TabWorld: View {
    @Binding var tab: String
    var onCapture: () -> Void

    var body: some View {
        ZStack {
            switch tab {
            case "discover": DiscoverFlow(tab: $tab, onCapture: onCapture)
            case "edu":      EducationFlow(tab: $tab, onCapture: onCapture)
            case "planner":  PlannerFlow(tab: $tab, onCapture: onCapture)
            default:         WardrobeFlow(tab: $tab, onCapture: onCapture)
            }
        }
    }
}

// MARK: - Journey 2 flow (camera → confirm → looking → result → expanded)

struct CameraFlow: View {
    var onClose: () -> Void
    var onGoWardrobe: () -> Void
    private enum Step { case camera, confirm, looking, result, expanded }
    @State private var step: Step = .camera

    var body: some View {
        ZStack {
            // base layer
            switch step {
            case .camera:
                CameraView(
                    onCapture: { go(.confirm) },
                    onBack: onClose,
                    onWardrobe: onGoWardrobe,
                    onContext: { go(.confirm) }
                ).transition(.opacity)
            case .confirm:
                ConfirmContextView(onConfirm: { go(.looking) }, onBack: { go(.camera) })
                    .transition(.opacity)
            case .looking:
                LookingView()
                    .transition(.opacity)
                    .task {
                        try? await Task.sleep(nanoseconds: 1_900_000_000)
                        go(.result)
                    }
            case .result, .expanded:
                ResultView(
                    onClose: onClose,
                    onTellMore: { go(.expanded) },
                    onGoWardrobe: onGoWardrobe
                ).transition(.opacity)
            }

            // expanded "tell me more" rises as a sheet over the result
            if step == .expanded {
                ExpandedView(onDismiss: { go(.result) })
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: step)
    }

    private func go(_ s: Step) { withAnimation(.easeInOut(duration: 0.4)) { step = s } }
}
