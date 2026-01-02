//
//  HeaderView.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//

import SwiftUI

struct HeaderView: View {
    @State private var showSettings = false
    @State private var selectedDetent: PresentationDetent = .large
    
    var body: some View {
        HStack {
            Text("App Title")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.leading)
            
            Spacer()
            
            Button(action: {
                selectedDetent = .large
                showSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(.trailing)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDetents([.large, .medium], selection: $selectedDetent)
        }
    }
}

#Preview {
    HeaderView()
}

