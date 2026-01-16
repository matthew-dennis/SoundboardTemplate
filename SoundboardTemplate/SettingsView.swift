//
//  SettingsView.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//
//  This view displays the app's settings screen where users can configure app preferences.

import SwiftUI

/// The settings view that allows users to configure app preferences.
/// Currently contains a placeholder for future settings options.
struct SettingsView: View {
    /// Environment value to dismiss the current view/sheet.
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            // List of settings options
            List {
                // Legal & Privacy Section
                Section("Legal & Privacy") {
                    Link(destination: URL(string: "https://example.com/privacy-policy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                }
                
                // Developer Section
                Section("Developer") {
                    Link(destination: URL(string: "https://example.com/developer")!) {
                        Label("Developer Website", systemImage: "globe")
                    }
                    
                    Link(destination: URL(string: "mailto:support@example.com")!) {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                }
                
                // App Section
                Section("App") {
                    Link(destination: URL(string: "https://apps.apple.com/app/id1234567890")!) {
                        Label("Rate This App", systemImage: "star.fill")
                    }
                    
                    Link(destination: URL(string: "https://apps.apple.com/developer/example")!) {
                        Label("Other Apps by Developer", systemImage: "square.grid.2x2.fill")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Done button in the navigation bar to dismiss the settings
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}




