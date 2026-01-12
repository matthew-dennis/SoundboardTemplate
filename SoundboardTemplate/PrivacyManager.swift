//
//  PrivacyManager.swift
//  SoundboardTemplate
//
//  This file manages App Tracking Transparency (ATT) permissions for ad personalization.
//  Required for iOS 14.5+ to request user permission before accessing IDFA.

import Foundation
import AppTrackingTransparency
import AdSupport

/// A singleton manager class that handles App Tracking Transparency (ATT) permissions.
/// This is required for iOS 14.5+ to request user permission before accessing the IDFA
/// (Identifier for Advertisers) for ad personalization.
class PrivacyManager {
    /// Shared singleton instance of PrivacyManager.
    static let shared = PrivacyManager()
    
    /// Private initializer to enforce singleton pattern.
    private init() {}
    
    /// Requests App Tracking Transparency permission from the user.
    /// Should be called after app launch with a short delay to ensure the app is fully loaded.
    /// - Parameter completion: Optional closure called with the authorization status result.
    func requestTrackingPermission(completion: ((ATTrackingManager.AuthorizationStatus) -> Void)? = nil) {
        // ATT is only available on iOS 14.5 and later
        if #available(iOS 14.5, *) {
            // Request tracking authorization, which shows the system permission dialog
            ATTrackingManager.requestTrackingAuthorization { status in
                // Handle the result on the main thread
                DispatchQueue.main.async {
                    self.handleTrackingStatus(status)
                    completion?(status)
                }
            }
        } else {
            // For iOS versions before 14.5, tracking is allowed by default
            completion?(.authorized)
        }
    }
    
    /// Gets the current tracking authorization status.
    /// - Returns: The current authorization status for app tracking.
    var trackingStatus: ATTrackingManager.AuthorizationStatus {
        if #available(iOS 14.5, *) {
            return ATTrackingManager.trackingAuthorizationStatus
        } else {
            // Pre-iOS 14.5, tracking is implicitly authorized
            return .authorized
        }
    }
    
    /// Checks if tracking is currently authorized.
    /// - Returns: True if tracking is authorized, false otherwise.
    var isTrackingAuthorized: Bool {
        return trackingStatus == .authorized
    }
    
    /// Handles the tracking authorization status and logs the result.
    /// - Parameter status: The authorization status returned from the system.
    private func handleTrackingStatus(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            // User granted permission - IDFA is available for ad personalization
            print("✅ Tracking authorized - IDFA available")
            // You can configure ad personalization here if needed
        case .denied:
            // User denied permission - limited ad personalization
            print("❌ Tracking denied - Limited ad personalization")
        case .restricted:
            // Tracking is restricted (e.g., parental controls) - limited ad personalization
            print("⚠️ Tracking restricted - Limited ad personalization")
        case .notDetermined:
            // Permission hasn't been requested yet
            print("⏳ Tracking not determined")
        @unknown default:
            // Handle any future status values
            print("❓ Unknown tracking status")
        }
    }
}



