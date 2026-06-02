//  FirebaseConfig.swift
//  Combin · Configuration
//
//  One place for Firebase startup (plan Steps 0.2 / 0.4):
//   • App Check provider is set BEFORE FirebaseApp.configure() — non-negotiable.
//   • Firestore offline persistence is asserted on.
//   • Remote Config in-app defaults are registered and a first fetch kicked off.
//
//  Guarded: if GoogleService-Info.plist isn't in the bundle yet, this no-ops with a
//  console warning so the design-system UI still runs before the Firebase project
//  exists. Once the plist ships, this path is never taken.

import Foundation
import FirebaseCore
import FirebaseAppCheck
import FirebaseFirestore
import FirebaseRemoteConfig

enum FirebaseConfig {

    /// Remote Config keys. Model names + prompt templates + limits live here — never
    /// hardcoded (architectural invariant #6).
    enum RCKey {
        static let stage1Model  = "stage1_model"
        static let stage2Model  = "stage2_model"
        static let stage1Prompt = "stage1_prompt_template"
        static let stage2Prompt = "stage2_prompt_template"
        static let dailyLimit   = "daily_vibe_check_limit"
    }

    /// Sensible defaults so the app behaves before the console values are set.
    ///
    /// ⚠️ Model names are PLACEHOLDERS — confirm the real available model in the
    /// Remote Config console. (The plan is internally inconsistent on the Stage 2
    /// name: the stack section says `gemini-3.5-flash`, Step 1.7 says
    /// `gemini-2.5-flash`. We default to the stack-section values; the flag wins.)
    private static let remoteConfigDefaults: [String: NSObject] = [
        RCKey.stage1Model: "gemini-3.1-flash-lite" as NSObject,
        RCKey.stage2Model: "gemini-3.5-flash" as NSObject,
        RCKey.dailyLimit: 1000 as NSObject,
        RCKey.stage1Prompt: PromptDefaults.stage1 as NSObject,
        RCKey.stage2Prompt: PromptDefaults.stage2 as NSObject,
    ]

    /// True once Firebase has actually been configured this launch.
    private(set) static var isConfigured = false

    static func configure() {
        guard Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil else {
            print("⚠️ Combin: GoogleService-Info.plist not found — running in UI-only mode. " +
                  "Add the plist to Combin/Configuration/ (and the target) to enable Firebase.")
            return
        }

        // App Check must be configured BEFORE FirebaseApp.configure() (Step 0.4).
        // DeviceCheck isn't available on the simulator, so use the debug provider
        // there — register its printed debug token in the App Check console to let
        // the simulator pass enforcement.
        #if targetEnvironment(simulator)
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(DeviceCheckProviderFactory())
        #endif

        FirebaseApp.configure()

        // Offline persistence is the iOS default; set it explicitly so the intent is
        // visible and a future SDK default change can't silently turn it off.
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings

        configureRemoteConfig()

        isConfigured = true
        print("Firebase configured")
    }

    private static func configureRemoteConfig() {
        let rc = RemoteConfig.remoteConfig()
        rc.setDefaults(remoteConfigDefaults)

        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0  // dev: always fresh. Raise before launch.
        rc.configSettings = settings

        rc.fetchAndActivate { status, error in
            if let error {
                print("Remote Config fetch failed: \(error.localizedDescription)")
            } else {
                let source = status == .successFetchedFromRemote ? "remote" : "cached/defaults"
                print("Remote Config ready (\(source))")
            }
        }
    }

    /// Convenience accessor used by the AI orchestrator.
    static func string(_ key: String, fallback: String) -> String {
        guard isConfigured else { return fallback }
        let value = RemoteConfig.remoteConfig().configValue(forKey: key).stringValue
        return value.isEmpty ? fallback : value
    }
}

/// The canonical Stage 1 / Stage 2 prompts, mirrored from
/// `combin-functions/src/prompts/*`. Shipped as Remote Config in-app defaults so the
/// app works before the console templates are authored; the console value overrides.
enum PromptDefaults {
    static let stage1 = """
    You are Combin — a fashion-literate friend who just got a photo of what someone is wearing and texts back fast. Warm, specific, confident, occasionally funny (humor as kindness, never ridicule).

    Look at the outfit and write ONE sentence reacting to it: 12 to 22 words, in that texting-a-stylish-friend voice. Make a specific observation about color, texture, proportion, or mood — not empty praise.

    Hard rules: never mention the person's body, shape, or size, or words like "flattering". Never use "wrong", "bad", "should", "must", "beautiful", "stunning", "okay", or "not bad". No scores, percentages, emoji, or hashtags. If you can't see a clear outfit, say so warmly and invite another angle.

    Return ONLY JSON matching the schema: "vibe_check" (the sentence) and "confidence" (0–1, how clearly you could read the outfit).
    """

    static let stage2 = """
    You are Combin, reading the same outfit more closely. Return JSON with three things, in the same warm, specific voice.

    "tweak": ONE optional one-sentence suggestion for a small change, or null if it already works. Use direction language ("try", "consider"); never criticize, command, or reference the body.

    "style_vector": score 0–100 on each axis (internal data, never shown to the user): vibe (clarity/intent), formality, colorfulness, cohesion, statement_strength.

    "garments": the distinct garments visible — each with category (outerwear/top/bottom/footwear/accessory), type, color, and confidence (0–1). Empty array if none are clear.

    Return ONLY JSON matching the schema. No body language, no scores in any text field, no emoji.
    """
}
