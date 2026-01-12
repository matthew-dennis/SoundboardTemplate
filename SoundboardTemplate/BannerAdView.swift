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
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        }
        
        // Load the ad request to fetch and display the advertisement
        banner.load(Request())
        return banner
    }
    
    /// Updates the banner view when SwiftUI state changes.
    /// Currently no updates are needed, so this is empty.
    /// - Parameters:
    ///   - uiView: The banner view to update.
    ///   - context: The context provided by SwiftUI.
    func updateUIView(_ uiView: BannerView, context: Context) {}
}
