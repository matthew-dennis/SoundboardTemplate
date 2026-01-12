//
//  HeaderView.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//
//  This file contains the header view that displays the app title and settings button.

import SwiftUI

/// The header view component that appears at the top of the app.
/// Displays the app title and a settings button that opens the settings sheet.
struct HeaderView: View {
    /// Controls whether the settings sheet is currently presented.
    @State private var showSettings = false
    
    /// Controls the presentation detent (size) of the settings sheet.
    /// Can be either .large or .medium.
    @State private var selectedDetent: PresentationDetent = .large
    
    var body: some View {
        // Horizontal stack containing title and settings button
        HStack {
            // App title text
            Text("App Title")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.leading)
            
            // Spacer pushes the settings button to the right
            Spacer()
            
            // Settings button that opens the settings sheet
            Button(action: {
                // Reset to large detent and show settings
                selectedDetent = .large
                showSettings = true
            }) {
                // Gear icon for settings
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(.trailing)
            }
        }
        .padding(.vertical) // Vertical padding for the header
        .background(Color(.systemBackground)) // Matches system background color
        // Present settings sheet when showSettings is true
        .sheet(isPresented: $showSettings) {
            SettingsView()
                // Allow sheet to be presented at large or medium size
                .presentationDetents([.large, .medium], selection: $selectedDetent)
        }
    }
}

#Preview {
    HeaderView()
}

