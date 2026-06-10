//  VibeCheckService.swift
//  Combin · Services
//
//  Streams the backend-owned vibe-check pipeline from a Supabase Edge Function.

import Foundation
import Supabase

enum VibeCheckError: Error {
    case emptyResponse
    case notConfigured
    case rateLimited
    case backend(String)
}

struct Stage1StreamPayload: Codable, Equatable {
    let text: String
    let confidence: Double
    let latencyMs: Int
}

struct Stage2StreamPayload: Codable, Equatable {
    let tweakText: String?
    let summary: String?
    let styleVector: StyleVector
    let styleTags: [String]?
    let palette: [ColorReading]?
    let photoQuality: PhotoQuality?
    let garments: [Garment]
    let latencyMs: Int
}

struct SavedVibeCheckPayload: Codable, Equatable {
    let vibeCheckId: String
    let garmentsWritten: Int
    let remaining: Int?
}

enum VibeCheckStreamEvent: Equatable {
    case stage1(Stage1StreamPayload)
    case stage2(Stage2StreamPayload)
    case saved(SavedVibeCheckPayload)
}

final class VibeCheckService {

    func process(photoPath: String, thumbPath: String?, device: VibeCheck.DeviceInfo) -> AsyncThrowingStream<VibeCheckStreamEvent, Error> {
        let request = ProcessVibeCheckRequest(photoPath: photoPath, thumbPath: thumbPath, device: device)
        let source = SupabaseConfig.requiredClient.functions._invokeWithStreamedResponse(
            BackendConfig.processVibeCheckFunction,
            options: FunctionInvokeOptions(method: .post, body: request)
        )

        return AsyncThrowingStream { continuation in
            let task = Task {
                var buffer = ""
                do {
                    for try await chunk in source {
                        buffer += String(decoding: chunk, as: UTF8.self)
                        try Self.drainFrames(from: &buffer, continuation: continuation)
                    }

                    if !buffer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                       let event = try Self.parseFrame(buffer) {
                        continuation.yield(event)
                    }
                    continuation.finish()
                } catch let FunctionsError.httpError(code, _) where code == 429 {
                    continuation.finish(throwing: VibeCheckError.rateLimited)
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private struct ProcessVibeCheckRequest: Encodable {
        let photoPath: String
        let thumbPath: String?
        let device: VibeCheck.DeviceInfo
    }

    private static func drainFrames(
        from buffer: inout String,
        continuation: AsyncThrowingStream<VibeCheckStreamEvent, Error>.Continuation
    ) throws {
        while let range = buffer.range(of: "\n\n") {
            let frame = String(buffer[..<range.lowerBound])
            buffer.removeSubrange(buffer.startIndex..<range.upperBound)
            if let event = try parseFrame(frame) {
                continuation.yield(event)
            }
        }
    }

    private static func parseFrame(_ frame: String) throws -> VibeCheckStreamEvent? {
        var eventName: String?
        var dataLines: [String] = []

        for rawLine in frame.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty, !line.hasPrefix(":") else { continue }
            if line.hasPrefix("event:") {
                eventName = String(line.dropFirst("event:".count)).trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("data:") {
                dataLines.append(String(line.dropFirst("data:".count)).trimmingCharacters(in: .whitespaces))
            }
        }

        guard let eventName, !dataLines.isEmpty else { return nil }
        let data = Data(dataLines.joined(separator: "\n").utf8)
        let decoder = JSONDecoder()

        switch eventName {
        case "stage1":
            return .stage1(try decoder.decode(Stage1StreamPayload.self, from: data))
        case "stage2":
            return .stage2(try decoder.decode(Stage2StreamPayload.self, from: data))
        case "saved":
            return .saved(try decoder.decode(SavedVibeCheckPayload.self, from: data))
        case "error":
            let payload = (try? decoder.decode(BackendErrorPayload.self, from: data))
            throw VibeCheckError.backend(payload?.message ?? "Backend error")
        default:
            return nil
        }
    }

    private struct BackendErrorPayload: Decodable {
        let message: String?
    }
}
