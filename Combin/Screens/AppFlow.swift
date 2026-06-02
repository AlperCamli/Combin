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
    @EnvironmentObject private var auth: AuthService
    private let uploader = PhotoUploadService()

    var body: some View {
        ZStack {
            switch auth.state {
            case .loading:
                SettingUpView().transition(.opacity)
            case .signedIn, .unavailable:
                Group {
                    if app.onboarded {
                        MainShell()
                    } else {
                        OnboardingFlow(onFinish: { app.completeOnboarding() })
                    }
                }
                .transition(.opacity)
            }
        }
        .environmentObject(app)
        .animation(.easeInOut(duration: 0.4), value: app.onboarded)
        .animation(.easeInOut(duration: 0.4), value: auth.state)
        // Retry any uploads that failed on a previous launch, once we have a uid.
        .task(id: auth.uid) {
            if let uid = auth.uid { await uploader.retryPending(uid: uid) }
        }
    }
}

/// First-launch only — shown while the anonymous session is being created.
private struct SettingUpView: View {
    var body: some View {
        ZStack {
            C.paper.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("Combin")
                    .serif(30, color: C.ink, tracking: -0.3)
                Text("Setting things up…")
                    .sans(14, color: C.inkSoft)
            }
        }
        .preferredColorScheme(.light)
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
    @EnvironmentObject private var auth: AuthService
    @State private var tab = "wardrobe"
    @State private var cameraPresented = true   // camera-first on launch

    var body: some View {
        TabWorld(tab: $tab, onCapture: { cameraPresented = true })
            .fullScreenCover(isPresented: $cameraPresented) {
                CameraFlow(
                    onClose: { cameraPresented = false },
                    onGoWardrobe: { tab = "wardrobe"; cameraPresented = false }
                )
                // Re-inject: environment objects don't reliably cross a fullScreenCover.
                .environmentObject(auth)
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

// MARK: - Journey 2 flow (camera → thinking → result → expanded)

/// The MVP core loop. Real capture, real Gemini orchestration via VibeCheckViewModel;
/// the screen shown follows the view model's phase rather than a timer.
struct CameraFlow: View {
    var onClose: () -> Void
    var onGoWardrobe: () -> Void

    @EnvironmentObject private var auth: AuthService
    @StateObject private var vm = VibeCheckViewModel()
    @State private var expanded = false

    var body: some View {
        ZStack {
            switch vm.phase {
            case .idle:
                CameraView(
                    onCapture: { image in vm.start(with: image, uid: auth.uid) },
                    onBack: onClose,
                    onWardrobe: onGoWardrobe
                ).transition(.opacity)

            case .processing:
                LookingView(image: vm.capturedImage)
                    .transition(.opacity)

            case .result, .failed:
                ResultView(
                    vm: vm,
                    onClose: { vm.reset(); onClose() },
                    onTellMore: { expanded = true },
                    onGoWardrobe: { vm.reset(); onGoWardrobe() },
                    onRetry: { vm.reset() }
                ).transition(.opacity)
            }

            // expanded "tell me more" rises as a sheet over the result
            if expanded {
                ExpandedView(vm: vm, onDismiss: { expanded = false })
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: vm.phase)
        .animation(.easeInOut(duration: 0.4), value: expanded)
    }
}
