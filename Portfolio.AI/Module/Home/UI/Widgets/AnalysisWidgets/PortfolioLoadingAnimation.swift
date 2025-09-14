//
//  PortfolioLoadingAnimation.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct PortfolioLoadingAnimation: View {
    @State private var isAnimating = false
    @State private var pulseScale = 1.0
    @State private var rotationAngle = 0.0
    @State private var opacity = 0.3
    var showText: Bool
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [AppColors.pureBackground, AppColors.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Animated logo/icon section
                ZStack {
                    // Outer pulsing rings
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                AppColors.selected.opacity(0.3 - Double(index) * 0.1),
                                lineWidth: 2
                            )
                            .frame(width: 120 + CGFloat(index * 30))
                            .scaleEffect(isAnimating ? 1.2 + Double(index) * 0.1 : 0.8)
                            .opacity(isAnimating ? 0.0 : 0.6)
                            .animation(
                                .easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                                value: isAnimating
                            )
                    }
                    
                    // Center animated icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.selected, AppColors.selected.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseScale)
                            .shadow(color: AppColors.selected.opacity(0.4), radius: 20, x: 0, y: 8)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.white)
                            .rotationEffect(.degrees(rotationAngle))
                    }
                }
                
                // Loading text section
                if(showText){
                    VStack(spacing: 16) {
                        Text("Loading Portfolio")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.textPrimary)
                        
                        Text("Fetching your investment data...")
                            .font(.body)
                            .foregroundStyle(AppColors.textSecondary)
                            .opacity(opacity)
                    }
                }
                
                // Animated dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(AppColors.selected)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
        
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            opacity = 1.0
        }
        
        isAnimating = true
    }
}

#Preview {
    PortfolioLoadingAnimation(showText: true)
}
