//
//  ShareSheet.swift
//  SoundboardTemplate
//
//  This file contains a SwiftUI wrapper for the native iOS share sheet (UIActivityViewController).

import SwiftUI

/// A SwiftUI view that wraps UIKit's UIActivityViewController to display the native iOS share sheet.
/// This allows users to share sound files via various methods (Messages, Mail, AirDrop, etc.).
struct ShareSheet: UIViewControllerRepresentable {
    /// Array of items to share (e.g., URLs, images, text).
    /// In this app, this typically contains a URL to a sound file.
    let activityItems: [Any]
    
    /// Optional closure called when the share sheet is dismissed.
    /// Use this to clean up temporary files.
    var onDismiss: (() -> Void)?
    
    /// Creates and configures the UIActivityViewController for sharing.
    /// - Parameter context: The context provided by SwiftUI for the view representation.
    /// - Returns: A configured UIActivityViewController ready to display the share sheet.
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Create the share sheet with the items to share
        // applicationActivities: nil means we only use system share options
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Set completion handler to clean up when dismissed
        controller.completionWithItemsHandler = { _, _, _, _ in
            onDismiss?()
        }
        
        return controller
    }
    
    /// Updates the share sheet when SwiftUI state changes.
    /// Currently no updates are needed, so this is empty.
    /// - Parameters:
    ///   - uiViewController: The share sheet controller to update.
    ///   - context: The context provided by SwiftUI.
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


