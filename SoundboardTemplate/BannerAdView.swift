//
//  BannerAdView.swift
//  SoundboardTemplate
//
//  This file contains the SwiftUI wrapper for displaying Google AdMob banner ads.
//  It bridges UIKit's GADBannerView to work within SwiftUI views.

import SwiftUI
import GoogleMobileAds

/// A SwiftUI view that displays a Google AdMob banner advertisement.
/// This struct conforms to UIViewRepresentable to bridge UIKit's GADBannerView into SwiftUI.
struct BannerAdView: UIViewRepresentable {
    /// The AdMob ad unit ID used to identify which ad to display.
    /// This should be replaced with your actual ad unit ID in production.
    let adUnitID: String
    
    /// Creates and configures the UIKit banner view for display in SwiftUI.
    /// - Parameter context: The context provided by SwiftUI for the view representation.
    /// - Returns: A configured GADBannerView ready to display ads.
    func makeUIView(context: Context) -> BannerView {
        // Create a banner view with standard banner size
        let banner = BannerView(adSize: AdSizeBanner)
        
        // Set the ad unit ID that identifies which ad to load
        banner.adUnitID = adUnitID
        
        // Get root view controller to properly present the ad
        // The banner needs a view controller to handle ad interactions
        if let rootViewController = getRootViewController() {
            banner.rootViewController = rootViewController
        } else {
            // Log warning if root view controller is not available
            // The ad won't load properly without a root view controller
            print("⚠️ BannerAdView: Root view controller not available. Ad may not load properly.")
        }
        
        // Load the ad request to fetch and display the advertisement
        banner.load(Request())
        return banner
    }
    
    /// Updates the banner view when SwiftUI state changes.
    /// Attempts to set rootViewController if it wasn't available initially.
    /// - Parameters:
    ///   - uiView: The banner view to update.
    ///   - context: The context provided by SwiftUI.
    func updateUIView(_ uiView: BannerView, context: Context) {
        // If rootViewController is still nil, try to set it again
        // This handles cases where the window wasn't ready during makeUIView
        if uiView.rootViewController == nil {
            if let rootViewController = getRootViewController() {
                uiView.rootViewController = rootViewController
                // Try loading the ad again now that we have a view controller
                uiView.load(Request())
                print("✅ BannerAdView: Root view controller set successfully on update")
            }
        }
    }
    
    /// Attempts to get the root view controller from the current window scene.
    /// - Returns: The root view controller if available, nil otherwise.
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        
        // Try to get rootViewController from the first window
        if let rootViewController = windowScene.windows.first?.rootViewController {
            return rootViewController
        }
        
        // Fallback: try to get from key window (for older iOS versions)
        if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
           let rootViewController = keyWindow.rootViewController {
            return rootViewController
        }
        
        return nil
    }
}
