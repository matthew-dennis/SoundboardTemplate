//
//  InitialRingtoneInstructionsView.swift
//  SoundboardTemplate
//

import SwiftUI

struct InitialRingtoneInstructionsView: View {
    @Environment(\.dismiss) var dismiss
    let onContinue: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Set as Ringtone")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text("To set this sound as your ringtone, you'll need to save it to your device first.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 16) {
                    InstructionStep(number: 1, text: "Save the sound file to your device")
                    
                    InstructionStep(number: 2, text: "Follow the instructions to set it as your ringtone")
                }
                .padding(.vertical)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                    onContinue()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save File")
                    }
                    .frame(maxWidth: .infinity)
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

