//
//  RingtoneInstructionsView.swift
//  SoundboardTemplate
//

import SwiftUI

struct RingtoneInstructionsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to Set as Ringtone")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 16) {
                    InstructionStep(number: 1, text: "Your sound file has been saved to Files")
                    
                    InstructionStep(number: 2, text: "Open the Settings app")
                    
                    InstructionStep(number: 3, text: "Go to Sounds & Haptics")
                    
                    InstructionStep(number: 4, text: "Tap on Ringtone")
                    
                    InstructionStep(number: 5, text: "Select your saved sound file from the list")
                }
                .padding(.vertical)
                
                Spacer()
                
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Open Settings")
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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    RingtoneInstructionsView()
}

