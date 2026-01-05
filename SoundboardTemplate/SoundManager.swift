//
//  SoundManager.swift
//  SoundboardTemplate
//

import Foundation
import AVFoundation
import Combine

class SoundManager: ObservableObject {
    private var audioPlayers: [Int: AVAudioPlayer] = [:]
    private var soundURLs: [Int: URL] = [:]
    
    init() {
        configureAudioSession()
    }
    
    func loadSound(at index: Int) {
        guard soundURLs[index] == nil else { return }
        
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
                soundURLs[index] = url
                print("Successfully loaded sound \(index)")
            } catch {
                print("Error loading sound \(index): \(error.localizedDescription)")
            }
        } else {
            print("Could not find sound file for sound_\(index).mp3")
        }
    }
    
    func loadSounds(count: Int) {
        for index in 1...count {
            loadSound(at: index)
        }
    }
    
    func playSound(at index: Int) {
        if let player = audioPlayers[index] {
            player.stop()
            player.currentTime = 0
            player.play()
        } else {
            print("Sound \(index) not loaded")
        }
    }
    
    func getSoundURL(at index: Int) -> URL? {
        return soundURLs[index]
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error configuring audio session: \(error.localizedDescription)")
        }
    }
}

