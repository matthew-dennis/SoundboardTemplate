//
//  SoundboardTemplateApp.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//

import SwiftUI
import GoogleMobileAds

@main
struct SoundboardTemplateApp: App {
    init() {
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
        
        // Request tracking permission after a short delay
        // This ensures the app is fully loaded before showing the ATT prompt
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            PrivacyManager.shared.requestTrackingPermission()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
