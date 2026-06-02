//  PhotoUploadService.swift
//  Combin · Services
//
//  Uploads outfit photos to Cloud Storage (plan Step 1.3).
//   • Path: users/{uid}/photos/{photoId}.jpg, contentType image/jpeg.
//   • Returns the gs:// URI (the same value stored on the vibe-check doc, and what
//     the extractGarments function matches against).
//   • On failure, the photo is kept in a local pending queue (file in Documents +
//     a UserDefaults manifest) and retried on the next launch.

import Foundation
import FirebaseStorage

final class PhotoUploadService {

    struct Upload: Equatable {
        let gsURI: String
        let storagePath: String
        let photoId: String
    }

    private let pendingKey = "combin.pendingUploads"

    // MARK: - Upload

    func upload(data: Data, uid: String) async throws -> Upload {
        let photoId = UUID().uuidString
        return try await upload(data: data, uid: uid, photoId: photoId)
    }

    private func upload(data: Data, uid: String, photoId: String) async throws -> Upload {
        let path = "users/\(uid)/photos/\(photoId).jpg"
        let ref = Storage.storage().reference(withPath: path)
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"

        do {
            _ = try await ref.putDataAsync(data, metadata: meta)
            let gsURI = "gs://\(ref.bucket)/\(ref.fullPath)"
            return Upload(gsURI: gsURI, storagePath: path, photoId: photoId)
        } catch {
            enqueuePending(data: data, photoId: photoId)
            throw error
        }
    }

    // MARK: - Pending queue (offline retry)

    private func enqueuePending(data: Data, photoId: String) {
        let url = pendingDirectory.appendingPathComponent("\(photoId).jpg")
        try? data.write(to: url)
        var ids = UserDefaults.standard.stringArray(forKey: pendingKey) ?? []
        if !ids.contains(photoId) { ids.append(photoId) }
        UserDefaults.standard.set(ids, forKey: pendingKey)
    }

    /// Re-attempt any uploads that failed previously. Call once on launch after auth
    /// resolves. Best-effort: failures stay queued for the next launch.
    func retryPending(uid: String) async {
        let ids = UserDefaults.standard.stringArray(forKey: pendingKey) ?? []
        guard !ids.isEmpty else { return }

        var remaining: [String] = []
        for id in ids {
            let url = pendingDirectory.appendingPathComponent("\(id).jpg")
            guard let data = try? Data(contentsOf: url) else { continue }  // file gone — drop it
            do {
                _ = try await upload(data: data, uid: uid, photoId: id)
                try? FileManager.default.removeItem(at: url)
            } catch {
                remaining.append(id)  // keep for next time
            }
        }
        UserDefaults.standard.set(remaining, forKey: pendingKey)
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
