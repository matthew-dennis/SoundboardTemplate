//
//  ContentView.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header area with app title and settings button
            HeaderView()
            
            // Scrollable grid of buttons
            SoundboardGridView()
            
            // AdMob banner ad at the bottom (test mode)
            BannerAdView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(height: 50)
        }
    }
}

#Preview {
    ContentView()
}
