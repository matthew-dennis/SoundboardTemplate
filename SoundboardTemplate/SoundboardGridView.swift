//
//  SoundboardGridView.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//

import SwiftUI
import UIKit

struct ShareableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct PendingRingtoneIndex: Identifiable {
    let id = UUID()
    let index: Int
}

struct SoundboardGridView: View {
    let numberOfButtons = 32
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    @StateObject private var soundManager = SoundManager()
    @State private var shareableURL: ShareableURL?
    @State private var pendingRingtoneIndex: PendingRingtoneIndex?
    @State private var showRingtoneInstructions = false
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1...numberOfButtons, id: \.self) { index in
                    SoundButton(
                        index: index,
                        onPlay: {
                            soundManager.playSound(at: index)
                        },
                        onSave: {
                            saveSound(at: index)
                        },
                        onShare: {
                            shareSound(at: index)
                        },
                        onSetAsRingtone: {
                            setAsRingtone(at: index)
                        }
                    )
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $shareableURL) { shareable in
            ShareSheet(activityItems: [shareable.url])
        }
        .sheet(item: $pendingRingtoneIndex) { pending in
            InitialRingtoneInstructionsView(onContinue: {
                // Small delay to ensure sheet is dismissed before showing save dialog
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    saveSoundForRingtone(at: pending.index)
                }
            })
        }
        .sheet(isPresented: $showRingtoneInstructions) {
            RingtoneInstructionsView()
        }
        .onAppear {
            soundManager.loadSounds(count: numberOfButtons)
        }
    }
    
    private func saveSound(at index: Int) {
        guard let url = soundManager.getSoundURL(at: index) else {
            print("Sound URL not found for index \(index)")
            return
        }
        
        // Get the root view controller to present the document picker
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
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
    
    private func shareSound(at index: Int) {
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
                    // Set the shareableURL, which will automatically show the sheet
                    shareableURL = ShareableURL(url: tempURL)
                case .failure(let error):
                    print("Error preparing sound for sharing: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func saveSoundForRingtone(at index: Int) {
        guard let url = soundManager.getSoundURL(at: index) else {
            print("Sound URL not found for index \(index)")
            return
        }
        
        // Get the root view controller to present the document picker
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
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
    
    private func setAsRingtone(at index: Int) {
        // First show initial instructions explaining the file must be saved
        // Reset first to ensure clean state
        pendingRingtoneIndex = nil
        // Set the pending index, which will automatically show the sheet
        pendingRingtoneIndex = PendingRingtoneIndex(index: index)
    }
}

#Preview {
    SoundboardGridView()
}


