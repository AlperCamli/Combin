//  PhotoUploadService.swift
//  Combin · Services
//
//  Uploads outfit photos to private Supabase Storage.

import Foundation
import Supabase

final class PhotoUploadService {

    struct Upload: Equatable {
        let photoPath: String
        let photoId: String
    }

    private let pendingKey = "combin.pendingUploads"

    func upload(data: Data, uid: String) async throws -> Upload {
        let photoId = UUID().uuidString
        return try await upload(data: data, uid: uid, photoId: photoId)
    }

    private func upload(data: Data, uid: String, photoId: String) async throws -> Upload {
        let path = "\(uid)/photos/\(photoId).jpg"

        do {
            try await SupabaseConfig.requiredClient.storage
                .from(BackendConfig.photoBucket)
                .upload(
                    path,
                    data: data,
                    options: FileOptions(contentType: "image/jpeg", upsert: false)
                )
            return Upload(photoPath: path, photoId: photoId)
        } catch {
            enqueuePending(data: data, photoId: photoId)
            throw error
        }
    }

    func retryPending(uid: String) async {
        guard SupabaseConfig.isConfigured else { return }

        let ids = UserDefaults.standard.stringArray(forKey: pendingKey) ?? []
        guard !ids.isEmpty else { return }

        var remaining: [String] = []
        for id in ids {
            let url = pendingDirectory.appendingPathComponent("\(id).jpg")
            guard let data = try? Data(contentsOf: url) else { continue }
            do {
                _ = try await upload(data: data, uid: uid, photoId: id)
                try? FileManager.default.removeItem(at: url)
            } catch {
                remaining.append(id)
            }
        }
        UserDefaults.standard.set(remaining, forKey: pendingKey)
    }

    private func enqueuePending(data: Data, photoId: String) {
        let url = pendingDirectory.appendingPathComponent("\(photoId).jpg")
        try? data.write(to: url)
        var ids = UserDefaults.standard.stringArray(forKey: pendingKey) ?? []
        if !ids.contains(photoId) { ids.append(photoId) }
        UserDefaults.standard.set(ids, forKey: pendingKey)
    }

    private var pendingDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("pendingUploads", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
}
