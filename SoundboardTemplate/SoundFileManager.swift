//
//  SoundFileManager.swift
//  SoundboardTemplate
//

import Foundation
import UniformTypeIdentifiers
import UIKit

class SoundFileManager {
    static let shared = SoundFileManager()
    private var activeDelegates: [DocumentPickerDelegate] = []
    
    private init() {}
    
    func saveSound(at url: URL, from viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        // Copy file to a temporary location that can be accessed by the document picker
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = url.lastPathComponent
        let destinationURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            // Remove existing file if present
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Copy file to temp directory
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            // Present document picker to save to Files app
            DispatchQueue.main.async {
                let documentPicker = UIDocumentPickerViewController(forExporting: [destinationURL], asCopy: true)
                
                // Create delegate with completion that removes itself from active list
                var delegate: DocumentPickerDelegate!
                delegate = DocumentPickerDelegate { [weak self] result in
                    // Remove delegate from active list when done
                    if let self = self, let index = self.activeDelegates.firstIndex(where: { $0 === delegate }) {
                        self.activeDelegates.remove(at: index)
                    }
                    completion(result)
                }
                
                // Retain the delegate
                self.activeDelegates.append(delegate)
                documentPicker.delegate = delegate
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(documentPicker, animated: true)
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    func shareSound(at url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        // Copy file to a temporary location that can be accessed by the share sheet
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = url.lastPathComponent
        let destinationURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            // Remove existing file if present
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Copy file to temp directory
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            DispatchQueue.main.async {
                completion(.success(destinationURL))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}

// Helper class to handle document picker delegate
class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    let completion: (Result<Void, Error>) -> Void
    
    init(completion: @escaping (Result<Void, Error>) -> Void) {
        self.completion = completion
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Document picker didPickDocumentsAt: \(urls)")
        // Add a small delay to ensure the picker is fully dismissed before calling completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.completion(.success(()))
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
        completion(.failure(SoundFileError.userCancelled))
    }
}

enum SoundFileError: LocalizedError {
    case photoLibraryAccessDenied
    case userCancelled
    case unknown
    
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

