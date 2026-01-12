//
//  SoundboardTemplateApp.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//
//  This is the main app entry point that initializes the app and sets up required services.

import SwiftUI
import GoogleMobileAds

/// The main app struct that serves as the entry point for the application.
@main
struct SoundboardTemplateApp: App {
    /// Initializes the app and sets up required services.
    init() {
        // Initialize Google Mobile Ads SDK
        // This must be called before displaying any ads
        MobileAds.shared.start(completionHandler: nil)
        
        // Request tracking permission after a short delay
        // This ensures the app is fully loaded before showing the ATT (App Tracking Transparency) prompt
        // A 1 second delay gives the UI time to render before the permission dialog appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            PrivacyManager.shared.requestTrackingPermission()
        }
    }
    
    /// Defines the app's scene structure.
    var body: some Scene {
        WindowGroup {
            // The main content view of the app
            ContentView()
        }
    }
}
