//  SupabaseConfig.swift
//  Combin · Configuration
//
//  One place for Supabase startup. If SupabaseConfig.plist is absent or still
//  contains placeholders, the app falls back to UI-only demo mode.

import Foundation
import Supabase

enum BackendConfig {
    static let photoBucket = "outfit-photos"
    static let processVibeCheckFunction = "process-vibe-check"
}

enum SupabaseConfig {
    private(set) static var isConfigured = false
    private(set) static var client: SupabaseClient?

    static func configure() {
        guard let values = loadValues(),
              let url = URL(string: values.url),
              isUsable(values.url),
              isUsable(values.publishableKey) else {
            print("Combin: SupabaseConfig.plist not found or incomplete - running in UI-only mode.")
            return
        }

        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: values.publishableKey,
            options: SupabaseClientOptions(
                db: .init(decoder: jsonDecoder),
                functions: .init(decoder: jsonDecoder)
            )
        )
        isConfigured = true
        print("Supabase configured")
    }

    static var requiredClient: SupabaseClient {
        guard let client else {
            preconditionFailure("Supabase client requested before configure() or without config.")
        }
        return client
    }

    private static func loadValues() -> (url: String, publishableKey: String)? {
        guard let url = Bundle.main.url(forResource: "SupabaseConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }

        guard let projectURL = plist["SUPABASE_URL"] as? String,
              let publishableKey = plist["SUPABASE_PUBLISHABLE_KEY"] as? String else {
            return nil
        }
        return (projectURL.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                publishableKey.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
    }

    private static func isUsable(_ value: String) -> Bool {
        !value.isEmpty && !value.contains("YOUR_") && !value.contains("example")
    }

    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            let fractional = ISO8601DateFormatter()
            fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = fractional.date(from: string) { return date }

            let plain = ISO8601DateFormatter()
            plain.formatOptions = [.withInternetDateTime]
            if let date = plain.date(from: string) { return date }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO-8601 date: \(string)"
            )
        }
        return decoder
    }()
}
