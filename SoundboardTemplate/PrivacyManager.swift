//
//  PrivacyManager.swift
//  SoundboardTemplate
//

import Foundation
import AppTrackingTransparency
import AdSupport

class PrivacyManager {
    static let shared = PrivacyManager()
    
    private init() {}
    
    /// Request App Tracking Transparency permission
    /// Should be called after app launch with a short delay
    func requestTrackingPermission(completion: ((ATTrackingManager.AuthorizationStatus) -> Void)? = nil) {
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    self.handleTrackingStatus(status)
                    completion?(status)
                }
            }
        } else {
            // For iOS < 14.5, tracking is allowed by default
            completion?(.authorized)
        }
    }
    
    /// Get current tracking authorization status
    var trackingStatus: ATTrackingManager.AuthorizationStatus {
        if #available(iOS 14.5, *) {
            return ATTrackingManager.trackingAuthorizationStatus
        } else {
            return .authorized
        }
    }
    
    /// Check if tracking is currently authorized
    var isTrackingAuthorized: Bool {
        return trackingStatus == .authorized
    }
    
    /// Handle the tracking authorization status
    private func handleTrackingStatus(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            print("✅ Tracking authorized - IDFA available")
            // You can configure ad personalization here if needed
        case .denied:
            print("❌ Tracking denied - Limited ad personalization")
        case .restricted:
            print("⚠️ Tracking restricted - Limited ad personalization")
        case .notDetermined:
            print("⏳ Tracking not determined")
        @unknown default:
            print("❓ Unknown tracking status")
        }
    }
}

