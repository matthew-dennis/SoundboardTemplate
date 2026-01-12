//
//  InitialRingtoneInstructionsView.swift
//  SoundboardTemplate
//
//  This view displays initial instructions before saving a sound file for use as a ringtone.

import SwiftUI

/// A view that shows initial instructions for setting a sound as a ringtone.
/// This is the first step in the ringtone setup process, explaining that the file must be saved first.
struct InitialRingtoneInstructionsView: View {
    /// Environment value to dismiss the current view/sheet.
    @Environment(\.dismiss) var dismiss
    
    /// Callback closure executed when the user taps "Save File".
    /// This triggers the file save process.
    let onContinue: () -> Void
    
    var body: some View {
        NavigationView {
            // Vertical stack with left alignment and spacing between elements
            VStack(alignment: .leading, spacing: 20) {
                // Title text
                Text("Set as Ringtone")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                // Explanation text about needing to save the file first
                Text("To set this sound as your ringtone, you'll need to save it to your device first.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                
                // List of instruction steps
                VStack(alignment: .leading, spacing: 16) {
                    InstructionStep(number: 1, text: "Save the sound file to your device")
                    
                    InstructionStep(number: 2, text: "Follow the instructions to set it as your ringtone")
                }
                .padding(.vertical)
                
                // Spacer pushes the button to the bottom
                Spacer()
                
                // Save File button that triggers the save process
                Button(action: {
                    // Dismiss this view and trigger the save action
                    dismiss()
                    onContinue()
                }) {
                    HStack {
                        // Download icon
                        Image(systemName: "square.and.arrow.down")
                        Text("Save File")
                    }
                    .frame(maxWidth: .infinity) // Full width button
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Set as Ringtone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button in the navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    InitialRingtoneInstructionsView(onContinue: {})
}

