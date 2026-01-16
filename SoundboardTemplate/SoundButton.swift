//
//  SoundButton.swift
//  SoundboardTemplate
//
//  This file contains the individual sound button component used in the soundboard grid.

import SwiftUI

/// A button component that represents a single sound in the soundboard.
/// Displays the sound number and provides actions for playing, saving, sharing, and setting as ringtone.
struct SoundButton: View {
    /// The index/number of this sound button (1-based).
    let index: Int
    
    /// Callback closure executed when the button is tapped to play the sound.
    let onPlay: () -> Void
    
    /// Callback closure executed when "Save sound" is selected from the context menu.
    let onSave: () -> Void
    
    /// Callback closure executed when "Share" is selected from the context menu.
    let onShare: () -> Void
    
    /// Callback closure executed when "Set as ringtone" is selected from the context menu.
    let onSetAsRingtone: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.black : Color(white: 0.8)
    }
    
    var body: some View {
        // Main button that plays the sound when tapped
        Button(action: onPlay) {
            // Button label showing the sound number
            ZStack(alignment: .bottom) {
                Color.blue
                    .aspectRatio(1, contentMode: .fit)
                
                Text("Sound \(index)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Rectangle()
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        // Context menu (long press) with additional options
        .contextMenu {
            // Save sound option
            Button(action: onSave) {
                Label("Save sound", systemImage: "square.and.arrow.down")
            }
            
            // Share sound option
            Button(action: onShare) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            // Set as ringtone option
            Button(action: onSetAsRingtone) {
                Label("Set as ringtone", systemImage: "bell.fill")
            }
        }
    }
}

