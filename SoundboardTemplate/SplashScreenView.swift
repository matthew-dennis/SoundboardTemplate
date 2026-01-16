//
//  SplashScreenView.swift
//  SoundboardTemplate
//
//  Created by Matthew Dennis on 12/26/25.
//
//  This view displays a splash screen with placeholder text and graphics during app initialization.

import SwiftUI

/// A splash screen view that displays during app launch.
/// Shows placeholder branding elements and transitions to the main content when ready.
struct SplashScreenView: View {
    /// Controls whether the splash screen should be dismissed.
    @Binding var isActive: Bool
    
    /// State for animation opacity
    @State private var opacity: Double = 0.0
    /// State for scale animation
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Background color matching system background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Main content stack
            VStack(spacing: 30) {
                Spacer()
                
                // Placeholder logo/icon graphic
                // Using a sound wave icon as a placeholder
                Image(systemName: "waveform.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.accentColor)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // App title placeholder
                Text("App Title")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(opacity)
                
                // Tagline placeholder
                Text("Your Soundboard Experience")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.secondary)
                    .opacity(opacity * 0.8)
                
                Spacer()
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                    .scaleEffect(1.2)
                    .opacity(opacity)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Animate the splash screen elements appearing
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1.0
                scale = 1.0
            }
        }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(true))
}
