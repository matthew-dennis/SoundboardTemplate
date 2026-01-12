//
//  RingtoneInstructionsView.swift
//  SoundboardTemplate
//
//  This view displays step-by-step instructions for setting a saved sound file as a ringtone.

import SwiftUI

/// A view that displays detailed instructions for setting a saved sound file as a ringtone.
/// This is shown after the user has saved the sound file to their device.
struct RingtoneInstructionsView: View {
    /// Environment value to dismiss the current view/sheet.
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            // Vertical stack with left alignment and spacing between elements
            VStack(alignment: .leading, spacing: 20) {
                // Title text
                Text("How to Set as Ringtone")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                // List of numbered instruction steps
                VStack(alignment: .leading, spacing: 16) {
                    InstructionStep(number: 1, text: "Your sound file has been saved to Files")
                    
                    InstructionStep(number: 2, text: "Open the Settings app")
                    
                    InstructionStep(number: 3, text: "Go to Sounds & Haptics")
                    
                    InstructionStep(number: 4, text: "Tap on Ringtone")
                    
                    InstructionStep(number: 5, text: "Select your saved sound file from the list")
                }
                .padding(.vertical)
                
                // Spacer pushes the button to the bottom
                Spacer()
                
                // Button that opens the iOS Settings app
                Button(action: {
                    // Open the Settings app using the system URL
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    // Dismiss this view after opening Settings
                    dismiss()
                }) {
                    HStack {
                        // Settings gear icon
                        Image(systemName: "gear")
                        Text("Open Settings")
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
                // Done button in the navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
    RingtoneInstructionsView()
}

