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
                
                // Explanation text about the share sheet process
                Text("A share sheet will appear. Select \"Use as Ringtone\" to add this sound to your ringtones.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                
                // List of instruction steps
                VStack(alignment: .leading, spacing: 16) {
                    InstructionStep(number: 1, text: "Tap the button below to open the share sheet")
                    
                    InstructionStep(number: 2, text: "Select \"Use as Ringtone\" from the share sheet")
                    
                    InstructionStep(number: 3, text: "Follow the instructions to set it as your ringtone")
                }
                .padding(.vertical)
                
                // Spacer pushes the button to the bottom
                Spacer()
                
                // Continue button that triggers the share sheet
                Button(action: {
                    // Dismiss this view and trigger the share sheet
                    dismiss()
                    onContinue()
                }) {
                    HStack {
                        // Share icon
                        Image(systemName: "square.and.arrow.up")
                        Text("Open Share Sheet")
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

/// A reusable view component that displays a numbered instruction step.
/// Shows a circular number badge followed by instruction text.
struct InstructionStep: View {
    /// The step number to display in the circular badge.
    let number: Int
    
    /// The instruction text to display next to the number.
    let text: String
    
    var body: some View {
        // Horizontal stack with top alignment
        HStack(alignment: .top, spacing: 12) {
            // Circular number badge
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .clipShape(Circle())
            
            // Instruction text
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            // Spacer pushes content to the left
            Spacer()
        }
    }
}

#Preview {
    InitialRingtoneInstructionsView(onContinue: {})
}

