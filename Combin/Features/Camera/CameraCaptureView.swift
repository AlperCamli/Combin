//  CameraCaptureView.swift
//  Combin · Features/Camera
//
//  Real capture for the vibe-check loop (plan Steps 1.1 / 1.2):
//   • CameraController — owns the AVCaptureSession, requests permission, and
//     captures a still as a UIImage (async).
//   • CameraPreview — a UIViewRepresentable wrapping AVCaptureVideoPreviewLayer.
//   • PhotoPicker — a PHPickerViewController wrapper for choosing an existing photo.
//   • UIImage.combinJPEGData() — compress to JPEG 0.75 at max 2048px long edge.
//
//  AVCaptureSession does not run on the simulator; `CameraController.isAvailable`
//  reports that so the UI can fall back to the gallery path for sim testing.

import SwiftUI
import AVFoundation
import PhotosUI
import UIKit

// MARK: - Controller

@MainActor
final class CameraController: NSObject, ObservableObject {
    let session = AVCaptureSession()

    @Published private(set) var isAuthorized = false
    @Published private(set) var isAvailable = true       // false on simulator / no camera
    @Published private(set) var isConfigured = false

    private let output = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "combin.camera.session")
    private var captureContinuation: CheckedContinuation<UIImage, Error>?

    enum CameraError: Error { case unavailable, permissionDenied, captureFailed }

    /// Ask for permission and build the session once.
    func configure() async {
        guard !isConfigured else { return }

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        default:
            isAuthorized = false
        }

        guard isAuthorized else { return }
        await buildSession()
    }

    private func buildSession() async {
        // Capture local references so the background closure never touches the
        // @MainActor `self`. AVFoundation wants its work off the main thread.
        let session = self.session
        let output = self.output

        let ok: Bool = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            sessionQueue.async {
                session.beginConfiguration()
                session.sessionPreset = .photo

                guard
                    let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                        ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                    let input = try? AVCaptureDeviceInput(device: device),
                    session.canAddInput(input),
                    session.canAddOutput(output)
                else {
                    session.commitConfiguration()
                    cont.resume(returning: false)
                    return
                }

                session.addInput(input)
                session.addOutput(output)
                session.commitConfiguration()
                cont.resume(returning: true)
            }
        }

        isAvailable = ok
        isConfigured = ok
    }

    func start() {
        guard isAuthorized, isAvailable else { return }
        let session = self.session
        sessionQueue.async {
            guard !session.isRunning else { return }
            session.startRunning()
        }
    }

    func stop() {
        let session = self.session
        sessionQueue.async {
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }

    /// Capture a single still. Throws if the camera isn't usable.
    func capture() async throws -> UIImage {
        guard isAuthorized, isAvailable, isConfigured else { throw CameraError.unavailable }
        let output = self.output
        let delegate: AVCapturePhotoCaptureDelegate = self
        return try await withCheckedThrowingContinuation { cont in
            captureContinuation = cont
            let settings = AVCapturePhotoSettings()
            sessionQueue.async {
                output.capturePhoto(with: settings, delegate: delegate)
            }
        }
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                 didFinishProcessingPhoto photo: AVCapturePhoto,
                                 error: Error?) {
        let result: Result<UIImage, Error>
        if let error {
            result = .failure(error)
        } else if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            result = .success(image)
        } else {
            result = .failure(CameraError.captureFailed)
        }
        Task { @MainActor in
            switch result {
            case .success(let image): self.captureContinuation?.resume(returning: image)
            case .failure(let err):   self.captureContinuation?.resume(throwing: err)
            }
            self.captureContinuation = nil
        }
    }
}

// MARK: - Preview layer

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

// MARK: - Photo picker (gallery)

struct PhotoPicker: UIViewControllerRepresentable {
    var onPick: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { object, _ in
                guard let image = object as? UIImage else { return }
                Task { @MainActor in self.parent.onPick(image) }
            }
        }
    }
}

// MARK: - Compression (plan Step 1.2)

extension UIImage {
    /// JPEG at quality 0.75, downscaled so the long edge is at most `maxEdge` px.
    /// Targets the plan's "< 400KB typical" upload size.
    func combinJPEGData(maxEdge: CGFloat = 2048, quality: CGFloat = 0.75) -> Data? {
        let longEdge = max(size.width, size.height)
        let image: UIImage
        if longEdge > maxEdge {
            let scale = maxEdge / longEdge
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = 1
            image = UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
                draw(in: CGRect(origin: .zero, size: newSize))
            }
        } else {
            image = self
        }
        return image.jpegData(compressionQuality: quality)
    }
}
