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
    /// Shared singleton instance of SoundManager.
    static let shared = SoundManager()
    
    /// Dictionary mapping sound indices to their AVAudioPlayer instances.
    /// Caches players to avoid reloading sounds on each play.
    private var audioPlayers: [Int: AVAudioPlayer] = [:]
    
    /// Dictionary mapping sound indices to their file URLs.
    /// Used to retrieve file URLs for saving and sharing operations.
    private var soundURLs: [Int: URL] = [:]
    
    /// The index of the most recently played sound.
    @Published var mostRecentSoundIndex: Int?
    
    /// Whether looping is currently enabled for the most recently played sound.
    @Published var isLooping: Bool = false
    
    /// The index of the sound that is currently set to loop (if any).
    private var loopingSoundIndex: Int?
    
    /// Global volume level for all audio players (0.0 to 1.0).
    @Published var volume: Float = 1.0 {
        didSet {
            // Update volume for all loaded players
            updateVolumeForAllPlayers()
        }
    }
    
    /// Whether playback is currently paused.
    @Published var isPaused: Bool = false
    
    /// Serial queue for thread-safe access to dictionaries.
    /// All dictionary read/write operations are synchronized through this queue.
    private let accessQueue = DispatchQueue(label: "com.soundboardtemplate.soundmanager", attributes: .concurrent)
    
    /// Private initializer to enforce singleton pattern.
    private init() {
        configureAudioSession()
    }
    
    /// Loads a sound file at the specified index and creates an AVAudioPlayer for it.
    /// Tries multiple methods to locate the sound file in the app bundle.
    /// - Parameter index: The index of the sound to load (1-based).
    func loadSound(at index: Int) {
        // Check if already loaded (thread-safe read)
        var alreadyLoaded = false
        accessQueue.sync {
            alreadyLoaded = soundURLs[index] != nil
        }
        guard !alreadyLoaded else { return }
        
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
                // Set initial volume
                player.volume = volume
                // Prepare the player for immediate playback (reduces latency)
                player.prepareToPlay()
                // Cache the player and URL for future use (thread-safe write)
                accessQueue.async(flags: .barrier) {
                    self.audioPlayers[index] = player
                    self.soundURLs[index] = url
                }
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
    /// If the sound is not loaded, attempts to load it first (lazy loading).
    /// Stops looping on any previously looping sound when a new sound is played.
    /// - Parameter index: The index of the sound to play (1-based).
    func playSound(at index: Int) {
        // Stop looping on previous sound if a new sound is being played
        if isLooping, let previousLoopingIndex = loopingSoundIndex, previousLoopingIndex != index {
            stopLooping()
        }
        
        // Thread-safe read to get the player
        var player: AVAudioPlayer?
        accessQueue.sync {
            player = audioPlayers[index]
        }
        
        if let player = player {
            // Sound is already loaded, play it
            // Stop any currently playing instance
            player.stop()
            // Reset to beginning
            player.currentTime = 0
            // Apply current volume
            player.volume = volume
            // Apply looping if enabled for this sound
            if isLooping && loopingSoundIndex == index {
                player.numberOfLoops = -1 // -1 means infinite loop
            } else {
                player.numberOfLoops = 0 // No loop
            }
            // Start playback
            player.play()
            // Update most recent sound and reset pause state
            DispatchQueue.main.async {
                self.mostRecentSoundIndex = index
                self.isPaused = false
            }
        } else {
            // Sound not loaded, attempt lazy loading
            print("Sound \(index) not loaded, attempting to load...")
            loadSound(at: index)
            
            // After loading attempt, check again (with a small delay to allow async write to complete)
            // Use a barrier sync to ensure the write has completed
            accessQueue.sync(flags: .barrier) {
                player = audioPlayers[index]
            }
            
            if let player = player {
                // Successfully loaded, now play it
                player.stop()
                player.currentTime = 0
                // Apply current volume
                player.volume = volume
                // Apply looping if enabled for this sound
                if isLooping && loopingSoundIndex == index {
                    player.numberOfLoops = -1 // -1 means infinite loop
                } else {
                    player.numberOfLoops = 0 // No loop
                }
                player.play()
                // Update most recent sound and reset pause state
                DispatchQueue.main.async {
                    self.mostRecentSoundIndex = index
                    self.isPaused = false
                }
                print("Sound \(index) loaded and played successfully")
            } else {
                // Still not available after loading attempt
                print("⚠️ Sound \(index) could not be loaded or file not found")
            }
        }
    }
    
    /// Gets the file URL for a sound at the specified index.
    /// - Parameter index: The index of the sound (1-based).
    /// - Returns: The URL of the sound file, or nil if not loaded.
    func getSoundURL(at index: Int) -> URL? {
        // Thread-safe read
        return accessQueue.sync {
            return soundURLs[index]
        }
    }
    
    /// Toggles looping for the most recently played sound.
    /// If no sound has been played yet, does nothing.
    /// Only one sound can loop at a time - if looping is enabled for a different sound, it will be disabled.
    func toggleLooping() {
        guard let recentIndex = mostRecentSoundIndex else {
            print("No sound has been played yet, cannot enable looping")
            return
        }
        
        if isLooping && loopingSoundIndex == recentIndex {
            // Currently looping this sound, disable looping
            stopLooping()
        } else {
            // Enable looping for the most recent sound
            startLooping(for: recentIndex)
        }
    }
    
    /// Starts looping for the specified sound index.
    /// Stops any previously looping sound.
    /// - Parameter index: The index of the sound to loop (1-based).
    private func startLooping(for index: Int) {
        // Stop previous looping if any
        if isLooping, let previousIndex = loopingSoundIndex {
            stopLoopingForSound(at: previousIndex)
        }
        
        // Get the player for this sound
        var player: AVAudioPlayer?
        accessQueue.sync {
            player = audioPlayers[index]
        }
        
        if let player = player {
            // Apply current volume
            player.volume = volume
            // Set infinite loop
            player.numberOfLoops = -1
            // If the sound is currently playing, it will continue and loop
            // If not playing, start it
            if !player.isPlaying {
                player.currentTime = 0
                player.play()
            }
            
            // Update state
            DispatchQueue.main.async {
                self.isLooping = true
                self.loopingSoundIndex = index
            }
            print("✅ Started looping sound \(index)")
        } else {
            print("⚠️ Cannot loop sound \(index) - sound not loaded")
        }
    }
    
    /// Stops looping for the currently looping sound.
    func stopLooping() {
        if let loopingIndex = loopingSoundIndex {
            stopLoopingForSound(at: loopingIndex)
        }
    }
    
    /// Stops looping for a specific sound index.
    /// - Parameter index: The index of the sound to stop looping (1-based).
    private func stopLoopingForSound(at index: Int) {
        var player: AVAudioPlayer?
        accessQueue.sync {
            player = audioPlayers[index]
        }
        
        if let player = player {
            // Set to no loop (will finish current playback)
            player.numberOfLoops = 0
            print("⏹️ Stopped looping sound \(index)")
        }
        
        // Update state
        DispatchQueue.main.async {
            self.isLooping = false
            self.loopingSoundIndex = nil
        }
    }
    
    /// Toggles pause/resume for all currently playing sounds.
    func togglePause() {
        var shouldPause = false
        
        // Check if any sounds are playing (thread-safe)
        accessQueue.sync {
            for (_, player) in self.audioPlayers {
                if player.isPlaying {
                    shouldPause = true
                    break
                }
            }
        }
        
        // If nothing is playing and we're not paused, nothing to do
        guard shouldPause || isPaused else {
            return
        }
        
        // Toggle pause/resume for all players
        accessQueue.sync(flags: .barrier) {
            for (_, player) in self.audioPlayers {
                if shouldPause {
                    // Pause all playing sounds
                    if player.isPlaying {
                        player.pause()
                    }
                } else if isPaused {
                    // Resume all paused sounds
                    if !player.isPlaying && player.currentTime > 0 {
                        player.play()
                    }
                }
            }
        }
        
        // Update pause state
        let newPauseState = shouldPause
        DispatchQueue.main.async {
            self.isPaused = newPauseState
        }
        
        print(newPauseState ? "⏸️ Paused all sounds" : "▶️ Resumed all sounds")
    }
    
    /// Stops all currently playing sounds.
    /// Also stops looping if enabled and resets pause state.
    func stopAll() {
        // Stop looping first
        if isLooping {
            stopLooping()
        }
        
        // Stop all players (thread-safe)
        accessQueue.sync(flags: .barrier) {
            for (_, player) in self.audioPlayers {
                player.stop()
                player.currentTime = 0
            }
        }
        
        // Reset pause state
        DispatchQueue.main.async {
            self.isPaused = false
        }
        
        print("⏹️ Stopped all sounds")
    }
    
    /// Updates the volume for all loaded audio players.
    private func updateVolumeForAllPlayers() {
        accessQueue.sync(flags: .barrier) {
            for (_, player) in self.audioPlayers {
                player.volume = self.volume
            }
        }
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

