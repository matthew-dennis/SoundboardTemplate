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
            // Vertical stack for settings content
            VStack {
                // Settings title
                Text("Settings")
                    .font(.title)
                    .padding()
                
                // Add your settings content here
                // This is a placeholder for future settings options such as:
                // - Volume controls
                // - Sound preferences
                // - App appearance
                // - About section
                
                // Spacer fills remaining space
                Spacer()
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




