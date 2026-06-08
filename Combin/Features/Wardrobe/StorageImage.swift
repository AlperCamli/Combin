//  StorageImage.swift
//  Combin · Features/Wardrobe
//
//  Loads a private image from Supabase Storage and caches it in memory.

import SwiftUI
import UIKit

enum StorageImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

@MainActor
final class StorageImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?

    func load(_ path: String) async {
        if let cached = StorageImageCache.shared.object(forKey: path as NSString) {
            image = cached
            return
        }
        guard SupabaseConfig.isConfigured, image == nil else { return }

        do {
            let data = try await SupabaseConfig.requiredClient.storage
                .from(BackendConfig.photoBucket)
                .download(path: path)
            if let img = UIImage(data: data) {
                StorageImageCache.shared.setObject(img, forKey: path as NSString)
                image = img
            }
        } catch {
            debugPrint("Combin · StorageImage load failed for \(path):", error)
        }
    }
}

struct StorageImage<Placeholder: View>: View {
    let path: String
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
        .task(id: path) { await loader.load(path) }
    }
}
