//
//  SoundButton.swift
//  SoundboardTemplate
//

import SwiftUI

struct SoundButton: View {
    let index: Int
    let onPlay: () -> Void
    let onSave: () -> Void
    let onShare: () -> Void
    let onSetAsRingtone: () -> Void
    
    var body: some View {
        Button(action: onPlay) {
            Text("Sound \(index)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .contextMenu {
            Button(action: onSave) {
                Label("Save sound", systemImage: "square.and.arrow.down")
            }
            
            Button(action: onShare) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Button(action: onSetAsRingtone) {
                Label("Set as ringtone", systemImage: "bell.fill")
            }
        }
    }
}

