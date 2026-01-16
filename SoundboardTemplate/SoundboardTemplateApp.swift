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
    /// Controls whether the splash screen is currently displayed.
    @State private var showSplash = true
    
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
            ZStack {
                if showSplash {
                    // Show splash screen during initialization
                    SplashScreenView(isActive: $showSplash)
                        .transition(.opacity)
                } else {
                    // Show main content after splash screen
                    ContentView()
                        .transition(.opacity)
                }
            }
            .onAppear {
                // Dismiss splash screen after initialization period
                // This gives time for ads SDK and other services to initialize
                // Adjust the delay as needed (currently 2 seconds)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
