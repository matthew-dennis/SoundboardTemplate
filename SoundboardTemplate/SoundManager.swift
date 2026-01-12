//
//  SoundManager.swift
//  SoundboardTemplate
//
//  This file manages loading and playing sound files using AVFoundation.

import Foundation
import AVFoundation
import Combine

/// A manager class that handles loading and playing sound files.
/// Maintains a cache of loaded audio players and their URLs for efficient playback.
class SoundManager: ObservableObject {
    /// Dictionary mapping sound indices to their AVAudioPlayer instances.
    /// Caches players to avoid reloading sounds on each play.
    private var audioPlayers: [Int: AVAudioPlayer] = [:]
    
    /// Dictionary mapping sound indices to their file URLs.
    /// Used to retrieve file URLs for saving and sharing operations.
    private var soundURLs: [Int: URL] = [:]
    
    /// Initializes the sound manager and configures the audio session.
    init() {
        configureAudioSession()
    }
    
    /// Loads a sound file at the specified index and creates an AVAudioPlayer for it.
    /// Tries multiple methods to locate the sound file in the app bundle.
    /// - Parameter index: The index of the sound to load (1-based).
    func loadSound(at index: Int) {
        // Skip if already loaded
        guard soundURLs[index] == nil else { return }
        
        var soundURL: URL?
        
        // Try loading from Sounds subdirectory first (most common location)
        soundURL = Bundle.main.url(forResource: "sound_\(index)", withExtension: "mp3", subdirectory: "Sounds")
        
        // If not found, try without subdirectory (root of bundle)
        if soundURL == nil {
            soundURL = Bundle.main.url(forResource: "sound_\(index)", withExtension: "mp3")
        }
        
        // If still not found, try with full path construction
        if soundURL == nil {
            if let bundlePath = Bundle.main.resourcePath {
                let fullPath = "\(bundlePath)/Sounds/sound_\(index).mp3"
                soundURL = URL(fileURLWithPath: fullPath)
                // Verify the file actually exists at this path
                if !FileManager.default.fileExists(atPath: fullPath) {
                    soundURL = nil
                }
            }
        }
        
        // If we found a valid URL, create and cache the audio player
        if let url = soundURL {
            do {
                // Create audio player from the file URL
                let player = try AVAudioPlayer(contentsOf: url)
                // Prepare the player for immediate playback (reduces latency)
                player.prepareToPlay()
                // Cache the player and URL for future use
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
    
    /// Loads multiple sound files in sequence.
    /// - Parameter count: The number of sounds to load (from 1 to count).
    func loadSounds(count: Int) {
        for index in 1...count {
            loadSound(at: index)
        }
    }
    
    /// Plays a sound at the specified index.
    /// Stops any currently playing instance and restarts from the beginning.
    /// - Parameter index: The index of the sound to play (1-based).
    func playSound(at index: Int) {
        if let player = audioPlayers[index] {
            // Stop any currently playing instance
            player.stop()
            // Reset to beginning
            player.currentTime = 0
            // Start playback
            player.play()
        } else {
            print("Sound \(index) not loaded")
        }
    }
    
    /// Gets the file URL for a sound at the specified index.
    /// - Parameter index: The index of the sound (1-based).
    /// - Returns: The URL of the sound file, or nil if not loaded.
    func getSoundURL(at index: Int) -> URL? {
        return soundURLs[index]
    }
    
    /// Configures the audio session for playback.
    /// Sets the category to playback mode so sounds play even when the device is silent.
    private func configureAudioSession() {
        do {
            // Set category to playback so sounds play even in silent mode
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            // Activate the audio session
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error configuring audio session: \(error.localizedDescription)")
        }
    }
}

