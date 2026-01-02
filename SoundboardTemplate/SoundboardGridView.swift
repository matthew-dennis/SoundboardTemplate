//
//  SoundboardGridView.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//

import SwiftUI

struct SoundboardGridView: View {
    let numberOfButtons = 32
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1...numberOfButtons, id: \.self) { index in
                    Button(action: {
                        // Button action - play sound
                        playSound(index: index)
                    }) {
                        Text("Sound \(index)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func playSound(index: Int) {
        // TODO: Implement sound playback
        print("Playing sound \(index)")
    }
}

#Preview {
    SoundboardGridView()
}

