//  StorageImage.swift
//  Combin · Features/Wardrobe
//
//  Loads an image from a gs:// Cloud Storage path and shows a placeholder until it
//  arrives, with a small in-memory cache so scrolling the Looks grid doesn't
//  re-download. Storage reads are App Check-gated like everything else.

import SwiftUI
import FirebaseStorage
import UIKit

enum StorageImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

@MainActor
final class StorageImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?

    func load(_ gsURI: String) async {
        if let cached = StorageImageCache.shared.object(forKey: gsURI as NSString) {
            image = cached
            return
        }
        guard image == nil else { return }
        do {
            let ref = Storage.storage().reference(forURL: gsURI)
            let data = try await ref.data(maxSize: 8 * 1024 * 1024)
            if let img = UIImage(data: data) {
                StorageImageCache.shared.setObject(img, forKey: gsURI as NSString)
                image = img
            }
        } catch {
            debugPrint("Combin · StorageImage load failed for \(gsURI):", error)
        }
    }
}

/// Fills its frame (`scaledToFill`); the caller is expected to set a frame and clip.
struct StorageImage<Placeholder: View>: View {
    let gsURI: String
    @ViewBuilder var placeholder: () -> Placeholder

    @StateObject private var loader = StorageImageLoader()

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder()
            }
        }
        .task(id: gsURI) { await loader.load(gsURI) }
    }
}
