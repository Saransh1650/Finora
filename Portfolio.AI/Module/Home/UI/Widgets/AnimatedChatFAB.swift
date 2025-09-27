//
//  AnimatedChatFAB.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 27/9/25.
//

import SwiftUI

struct AnimatedChatFAB: View {
    let action: () -> Void
    
    @State private var isBreathing = false
    @State private var pulseOpacity: Double = 0.3
    @State private var glowIntensity: Double = 0.3
    @State private var isTapped = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(
                        RadialGradient(
                            colors: [Color.blue.opacity(glowIntensity), Color.blue.opacity(0)],
                            center: .center,
                            startRadius: 25,
                            endRadius: 40
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(isBreathing ? 1.1 : 1.0)
                
                // Pulse ring
                Circle()
                    .stroke(Color.blue.opacity(pulseOpacity), lineWidth: 1.5)
                    .frame(width: 68, height: 68)
                    .scaleEffect(isBreathing ? 1.05 : 1.0)
                
                // Main FAB
                ZStack {
                    // Background circle with subtle shadow
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: .blue.opacity(0.4), radius: isBreathing ? 8 : 6, x: 0, y: 4)
                    
                    // Chat icon
                    Image(systemName: "message.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .scaleEffect(isBreathing ? 1.02 : 1.0)
                }
                .scaleEffect(isTapped ? 0.92 : 1.0)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            startAnimations()
        }
        .onTapGesture {
            // Tap animation
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isTapped = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isTapped = false
                }
            }
            
            action()
        }
    }
    
    private func startAnimations() {
        // Gentle breathing animation - subtle scale change
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            isBreathing = true
        }
        
        // Pulse opacity animation for the rings
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseOpacity = 0.1
        }
        
        // Subtle glow intensity animation
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            glowIntensity = 0.6
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        AnimatedChatFAB {
            print("Chat FAB tapped!")
        }
    }
}