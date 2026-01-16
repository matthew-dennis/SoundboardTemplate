//
//  AudioControlBar.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//
//  This file contains the audio control bar component that displays playback controls and information.

import SwiftUI

/// An audio control bar that provides playback control buttons.
/// Integrates with the app's design system.
struct AudioControlBar: View {
    /// Sound manager that handles loading and playing sounds.
    @ObservedObject private var soundManager = SoundManager.shared
    
    /// Environment value for color scheme (dark/light mode).
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Stop button
            Button(action: {
                soundManager.stopAll()
            }) {
                Image(systemName: "stop.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(soundManager.mostRecentSoundIndex == nil)
            .opacity(soundManager.mostRecentSoundIndex == nil ? 0.5 : 1.0)
            
            // Pause/Play button
            Button(action: {
                soundManager.togglePause()
            }) {
                Image(systemName: soundManager.isPaused ? "play.fill" : "pause.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(soundManager.mostRecentSoundIndex == nil)
            .opacity(soundManager.mostRecentSoundIndex == nil ? 0.5 : 1.0)
            
            // Volume slider
            HStack(spacing: 8) {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 16)
                
                Slider(value: Binding(
                    get: { Double(soundManager.volume) },
                    set: { soundManager.volume = Float($0) }
                ), in: 0...1)
                .tint(.blue)
                
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 16)
            }
            
            // Loop toggle button
            Button(action: {
                soundManager.toggleLooping()
            }) {
                Image(systemName: soundManager.isLooping ? "repeat.circle.fill" : "repeat.circle")
                    .font(.title2)
                    .foregroundColor(soundManager.isLooping ? .blue : .secondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(soundManager.isLooping ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(soundManager.mostRecentSoundIndex == nil)
            .opacity(soundManager.mostRecentSoundIndex == nil ? 0.5 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(height: 50)
        .background(
            Rectangle()
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: -1)
        )
        .overlay(
            Rectangle()
                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                .frame(height: 1),
            alignment: .top
        )
    }
}

#Preview {
    VStack {
        Spacer()
        AudioControlBar()
    }
    .background(Color(.systemGroupedBackground))
}
