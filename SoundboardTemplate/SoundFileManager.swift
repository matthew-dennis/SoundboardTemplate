//
//  SoundFileManager.swift
//  SoundboardTemplate
//
//  This file manages saving and sharing sound files using the document picker and share sheet.

import Foundation
import UniformTypeIdentifiers
import UIKit

/// A singleton manager class that handles saving and sharing sound files.
/// Provides functionality to save sounds to the Files app and prepare files for sharing.
class SoundFileManager {
    /// Shared singleton instance of SoundFileManager.
    static let shared = SoundFileManager()
    
    /// Array of active document picker delegates to retain them during file operations.
    /// This prevents delegates from being deallocated before the picker completes.
    private var activeDelegates: [DocumentPickerDelegate] = []
    
    /// Serial queue for thread-safe access to activeDelegates array.
    /// All array read/write operations are synchronized through this queue.
    private let delegatesQueue = DispatchQueue(label: "com.soundboardtemplate.soundfilemanager.delegates")
    
    /// Private initializer to enforce singleton pattern.
    private init() {}
    
    /// Saves a sound file to the device using the document picker.
    /// Copies the file to a temporary location and presents the document picker for the user to choose a save location.
    /// - Parameters:
    ///   - url: The URL of the sound file to save.
    ///   - viewController: The view controller to present the document picker from.
    ///   - completion: Closure called with the result of the save operation.
    func saveSound(at url: URL, from viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        // Copy file to a temporary location that can be accessed by the document picker
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = url.lastPathComponent
        let destinationURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            // Remove existing file if present to avoid conflicts
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Copy file to temp directory so it can be accessed by the document picker
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            // Present document picker to save to Files app
            DispatchQueue.main.async {
                // Create document picker for exporting the file
                // asCopy: true means the file will be copied, not moved
                let documentPicker = UIDocumentPickerViewController(forExporting: [destinationURL], asCopy: true)
                
                // Create delegate with completion that removes itself from active list and cleans up temp file
                var delegate: DocumentPickerDelegate!
                delegate = DocumentPickerDelegate(tempFileURL: destinationURL) { [weak self] result in
                    // Clean up temporary file
                    if let tempURL = delegate.tempFileURL {
                        try? FileManager.default.removeItem(at: tempURL)
                    }
                    
                    // Remove delegate from active list when done to prevent memory leaks (thread-safe)
                    if let self = self {
                        self.delegatesQueue.async {
                            if let index = self.activeDelegates.firstIndex(where: { $0 === delegate }) {
                                self.activeDelegates.remove(at: index)
                            }
                        }
                    }
                    completion(result)
                }
                
                // Retain the delegate to prevent it from being deallocated (thread-safe)
                // Use sync to ensure delegate is added before picker is presented
                self.delegatesQueue.sync {
                    self.activeDelegates.append(delegate)
                }
                documentPicker.delegate = delegate
                
                // Present the document picker from the root view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(documentPicker, animated: true)
                } else {
                    // If root view controller is unavailable, clean up temp file, delegate, and report error
                    if let tempURL = delegate.tempFileURL {
                        try? FileManager.default.removeItem(at: tempURL)
                    }
                    self.delegatesQueue.async {
                        if let index = self.activeDelegates.firstIndex(where: { $0 === delegate }) {
                            self.activeDelegates.remove(at: index)
                        }
                    }
                    completion(.failure(SoundFileError.unknown))
                }
            }
        } catch {
            // Handle file copy errors
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    /// Prepares a sound file for sharing by copying it to a temporary location.
    /// The temporary URL can then be used with the share sheet.
    /// Note: The caller is responsible for cleaning up the temporary file after sharing is complete.
    /// - Parameters:
    ///   - url: The URL of the sound file to share.
    ///   - completion: Closure called with the result containing the temporary URL or an error.
    func shareSound(at url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        // Copy file to a temporary location that can be accessed by the share sheet
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = url.lastPathComponent
        let destinationURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            // Remove existing file if present to avoid conflicts
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Copy file to temp directory so it can be shared
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            // Return the temporary URL on the main thread
            DispatchQueue.main.async {
                completion(.success(destinationURL))
            }
        } catch {
            // Handle file copy errors
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    /// Cleans up a temporary file at the specified URL.
    /// Safe to call even if the file doesn't exist.
    /// - Parameter url: The URL of the temporary file to delete.
    func cleanupTempFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}

/// Helper class to handle document picker delegate callbacks.
/// Retains the completion handler and manages the picker lifecycle.
class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    /// Completion closure called when the document picker finishes or is cancelled.
    let completion: (Result<Void, Error>) -> Void
    
    /// Temporary file URL that should be cleaned up after the picker completes.
    let tempFileURL: URL?
    
    /// Initializes the delegate with a completion handler and optional temp file URL.
    /// - Parameters:
    ///   - tempFileURL: Optional temporary file URL to clean up after completion.
    ///   - completion: Closure called with the result of the document picker operation.
    init(tempFileURL: URL? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        self.tempFileURL = tempFileURL
        self.completion = completion
    }
    
    /// Called when the user successfully picks documents in the document picker.
    /// - Parameters:
    ///   - controller: The document picker controller.
    ///   - urls: The URLs of the selected documents.
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Document picker didPickDocumentsAt: \(urls)")
        // Add a small delay to ensure the picker is fully dismissed before calling completion
        // This prevents UI conflicts when showing subsequent sheets
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.completion(.success(()))
        }
    }
    
    /// Called when the user cancels the document picker.
    /// - Parameter controller: The document picker controller.
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
        // Call completion with cancellation error
        completion(.failure(SoundFileError.userCancelled))
    }
}

/// Error types that can occur during sound file operations.
enum SoundFileError: LocalizedError {
    /// Photo library access was denied by the user.
    case photoLibraryAccessDenied
    
    /// User cancelled the file operation.
    case userCancelled
    
    /// An unknown error occurred.
    case unknown
    
    /// Human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .photoLibraryAccessDenied:
            return "Photo library access denied"
        case .userCancelled:
            return "Save cancelled"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

