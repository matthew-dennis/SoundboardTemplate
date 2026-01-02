//
//  SoundboardGridView.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//

import SwiftUI
import AVFoundation

struct SoundboardGridView: View {
    let numberOfButtons = 32
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    @State private var audioPlayers: [Int: AVAudioPlayer] = [:]
    
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
        .onAppear {
            configureAudioSession()
            loadSounds()
        }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error configuring audio session: \(error.localizedDescription)")
        }
    }
    
    private func loadSounds() {
        for index in 1...numberOfButtons {
            var soundURL: URL?
            
            // Try loading from Sounds subdirectory first
            soundURL = Bundle.main.url(forResource: "sound_\(index)", withExtension: "mp3", subdirectory: "Sounds")
            
            // If not found, try without subdirectory
            if soundURL == nil {
                soundURL = Bundle.main.url(forResource: "sound_\(index)", withExtension: "mp3")
            }
            
            // If still not found, try with full path
            if soundURL == nil {
                if let bundlePath = Bundle.main.resourcePath {
                    let fullPath = "\(bundlePath)/Sounds/sound_\(index).mp3"
                    soundURL = URL(fileURLWithPath: fullPath)
                    if !FileManager.default.fileExists(atPath: fullPath) {
                        soundURL = nil
                    }
                }
            }
            
            if let url = soundURL {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[index] = player
                    print("Successfully loaded sound \(index)")
                } catch {
                    print("Error loading sound \(index): \(error.localizedDescription)")
                }
            } else {
                print("Could not find sound file for sound_\(index).mp3")
            }
        }
    }
    
    private func playSound(index: Int) {
        if let player = audioPlayers[index] {
            player.stop()
            player.currentTime = 0
            player.play()
        } else {
            print("Sound \(index) not loaded")
        }
    }
}

#Preview {
    SoundboardGridView()
}


