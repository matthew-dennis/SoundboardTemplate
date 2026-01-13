//
//  SoundboardGridView.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//
//  This file contains the main grid view that displays all sound buttons in a scrollable grid layout.

import SwiftUI
import UIKit

/// A data structure representing a URL that can be shared via the share sheet.
/// Used to trigger the share sheet presentation when a sound file is ready to share.
struct ShareableURL: Identifiable {
    /// Unique identifier for SwiftUI list/sheet presentation.
    let id = UUID()
    
    /// The URL of the file to share.
    let url: URL
}

/// A data structure representing a sound index that is pending ringtone setup.
/// Used to trigger the initial ringtone instructions view.
struct PendingRingtoneIndex: Identifiable {
    /// Unique identifier for SwiftUI list/sheet presentation.
    let id = UUID()
    
    /// The index of the sound button that triggered the ringtone setup.
    let index: Int
}

/// The main grid view that displays all sound buttons in a scrollable 2-column layout.
/// Handles sound playback, saving, sharing, and ringtone setup functionality.
struct SoundboardGridView: View {
    /// Total number of sound buttons to display in the grid.
    let numberOfButtons = 32
    
    /// Grid layout configuration: 2 flexible columns with 10pt spacing.
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    /// Sound manager that handles loading and playing sounds.
    @StateObject private var soundManager = SoundManager()
    
    /// Optional shareable URL that triggers the share sheet when set.
    @State private var shareableURL: ShareableURL?
    
    /// Optional pending ringtone index that triggers initial instructions when set.
    @State private var pendingRingtoneIndex: PendingRingtoneIndex?
    
    /// Boolean that controls whether the ringtone instructions view is shown.
    @State private var showRingtoneInstructions = false
    
    var body: some View {
        // Scrollable view containing the grid
        ScrollView {
            // Lazy vertical grid that only renders visible items for performance
            LazyVGrid(columns: columns, spacing: 10) {
                // Create a button for each sound (1 through numberOfButtons)
                ForEach(1...numberOfButtons, id: \.self) { index in
                    SoundButton(
                        index: index,
                        onPlay: {
                            // Play the sound when button is tapped
                            soundManager.playSound(at: index)
                        },
                        onSave: {
                            // Save the sound file to device
                            saveSound(at: index)
                        },
                        onShare: {
                            // Share the sound file via share sheet
                            shareSound(at: index)
                        },
                        onSetAsRingtone: {
                            // Initiate ringtone setup process
                            setAsRingtone(at: index)
                        }
                    )
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Present share sheet when shareableURL is set
        .sheet(item: $shareableURL) { shareable in
            ShareSheet(activityItems: [shareable.url]) {
                // Clean up temporary file when share sheet is dismissed
                SoundFileManager.shared.cleanupTempFile(at: shareable.url)
            }
        }
        // Present initial ringtone instructions when pendingRingtoneIndex is set
        .sheet(item: $pendingRingtoneIndex) { pending in
            InitialRingtoneInstructionsView(onContinue: {
                // Small delay to ensure sheet is dismissed before showing save dialog
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    saveSoundForRingtone(at: pending.index)
                }
            })
        }
        // Present final ringtone instructions after file is saved
        .sheet(isPresented: $showRingtoneInstructions) {
            RingtoneInstructionsView()
        }
        // Load all sounds when the view appears
        .onAppear {
            soundManager.loadSounds(count: numberOfButtons)
        }
    }
    
    /// Saves a sound file to the device using the document picker.
    /// - Parameter index: The index of the sound button to save.
    private func saveSound(at index: Int) {
        // Get the URL of the sound file
        guard let url = soundManager.getSoundURL(at: index) else {
            print("Sound URL not found for index \(index)")
            return
        }
        
        // Get the root view controller to present the document picker
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // Save the sound file using the file manager
            SoundFileManager.shared.saveSound(at: url, from: rootViewController) { result in
                switch result {
                case .success:
                    print("Sound saved successfully")
                case .failure(let error):
                    print("Error saving sound: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Prepares and shares a sound file via the native share sheet.
    /// - Parameter index: The index of the sound button to share.
    private func shareSound(at index: Int) {
        // Get the URL of the sound file
        guard let url = soundManager.getSoundURL(at: index) else {
            print("Sound URL not found for index \(index)")
            return
        }
        
        // Reset shareableURL first to ensure clean state
        shareableURL = nil
        
        // Copy file to temporary location for sharing
        SoundFileManager.shared.shareSound(at: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tempURL):
                    // Set the shareableURL, which will automatically show the share sheet
                    shareableURL = ShareableURL(url: tempURL)
                case .failure(let error):
                    print("Error preparing sound for sharing: \(error.localizedDescription)")
                    // Note: No temp file was created in error case, so no cleanup needed
                }
            }
        }
    }
    
    /// Saves a sound file for ringtone setup and shows instructions after successful save.
    /// - Parameter index: The index of the sound button to set as ringtone.
    private func saveSoundForRingtone(at index: Int) {
        // Get the URL of the sound file
        guard let url = soundManager.getSoundURL(at: index) else {
            print("Sound URL not found for index \(index)")
            return
        }
        
        // Get the root view controller to present the document picker
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // Save the sound file using the file manager
            SoundFileManager.shared.saveSound(at: url, from: rootViewController) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Save successful, showing ringtone instructions")
                        // After successful save, show ringtone instructions
                        // Add a small delay to ensure document picker is fully dismissed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.showRingtoneInstructions = true
                        }
                    case .failure(let error):
                        if case SoundFileError.userCancelled = error {
                            // User cancelled, don't show instructions
                            print("Save cancelled")
                        } else {
                            print("Error saving sound: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    /// Initiates the ringtone setup process by showing initial instructions.
    /// - Parameter index: The index of the sound button to set as ringtone.
    private func setAsRingtone(at index: Int) {
        // First show initial instructions explaining the file must be saved
        // Reset first to ensure clean state
        pendingRingtoneIndex = nil
        // Set the pending index, which will automatically show the initial instructions sheet
        pendingRingtoneIndex = PendingRingtoneIndex(index: index)
    }
}

#Preview {
    SoundboardGridView()
}


