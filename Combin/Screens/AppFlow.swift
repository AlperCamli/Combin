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

/// The non-camera tabs. Journeys 3–6 are next round; each tab shows an on-brand
/// placeholder so the reusable TabBar is fully wired.
private struct TabWorld: View {
    @Binding var tab: String
    var onCapture: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            PlaceholderJourney(tab: tab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            TabBar(active: tab,
                   onSelect: { tab = $0 },
                   onCapture: onCapture)
        }
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

private struct PlaceholderJourney: View {
    var tab: String

    private var title: String {
        switch tab {
        case "discover": return "Discover"
        case "edu":      return "Education"
        case "planner":  return "Planner"
        default:          return "Wardrobe"
        }
    }
    private var blurb: String {
        switch tab {
        case "discover": return "An editorial catalogue — no prices, ever. Brands, movements, and references worth your attention."
        case "edu":      return "Daily Insight and the Daily Puzzle. Built to teach, never to sell."
        case "planner":  return "Tell me where you're headed and I'll compose two or three ideas from your closet."
        default:          return "Your fashion history — a grid of vibe-checks, with Items behind a toggle for power users."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title).serif(22, color: C.ink, tracking: -0.2)
                Spacer()
                Sym(name: "dots", size: 18, color: C.inkSoft)
            }
            .padding(.horizontal, 24).padding(.top, 12)

            Text(blurb)
                .sans(13, color: C.inkSoft, lineHeight: 1.55)
                .padding(.leading, 12)
                .overlay(alignment: .leading) { Rectangle().fill(C.paperLine).frame(width: 1) }
                .padding(.horizontal, 24).padding(.top, 14)

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                MonoMarker("round two")
                Text("More of this, soon.")
                    .serif(22, color: C.ink, tracking: -0.2, lineHeight: 1.2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
