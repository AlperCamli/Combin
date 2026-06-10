//  PhotoUploadService.swift
//  Combin · Services
//
//  Uploads outfit photos to private Supabase Storage.

import Foundation
import Supabase

final class PhotoUploadService {

    struct Upload: Equatable {
        let photoPath: String
        let thumbPath: String?
        let photoId: String
    }

    private let pendingKey = "combin.pendingUploads"

    /// Uploads the full photo (required) and a small grid thumbnail (best-effort —
    /// a failed thumb never fails the vibe-check).
    func upload(data: Data, thumbData: Data? = nil, uid: String) async throws -> Upload {
        let photoId = UUID().uuidString
        let upload = try await upload(data: data, uid: uid, photoId: photoId)

        guard let thumbData else { return upload }
        let thumbPath = "\(uid)/photos/\(photoId)_thumb.jpg"
        do {
            try await SupabaseConfig.requiredClient.storage
                .from(BackendConfig.photoBucket)
                .upload(
                    thumbPath,
                    data: thumbData,
                    options: FileOptions(contentType: "image/jpeg", upsert: false)
                )
            return Upload(photoPath: upload.photoPath, thumbPath: thumbPath, photoId: photoId)
        } catch {
            debugPrint("Combin · thumb upload failed (continuing without):", error)
            return upload
        }
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
            return Upload(photoPath: path, thumbPath: nil, photoId: photoId)
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
