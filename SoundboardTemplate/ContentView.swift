//
//  ContentView.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//
//  This is the main content view of the app, containing the header, soundboard grid, and banner ad.

import SwiftUI

/// The main content view that serves as the root of the app's user interface.
/// It arranges the header, soundboard grid, and banner ad in a vertical stack.
struct ContentView: View {
    var body: some View {
        // Vertical stack with no spacing between elements
        VStack(spacing: 0) {
            // Header area with app title and settings button
            HeaderView()
            
            // Scrollable grid of sound buttons
            SoundboardGridView()
            
            // AdMob banner ad at the bottom (test mode)
            // Note: This is a test ad unit ID. Replace with your production ad unit ID.
            BannerAdView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(height: 50) // Standard banner ad height
        }
    }
}

#Preview {
    ContentView()
}
