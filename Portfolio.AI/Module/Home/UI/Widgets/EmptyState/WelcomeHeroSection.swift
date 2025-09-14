//
//  WelcomeHeroSection.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct WelcomeHeroSection: View {
    var body: some View {
        VStack(spacing: 24) {
            // AI Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.selected.opacity(0.2), AppColors.selected.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(AppColors.selected)
            }
            .shadow(color: AppColors.selected.opacity(0.2), radius: 20, x: 0, y: 8)
            
            VStack(spacing: 12) {
                Text("AI-Powered Portfolio Analysis")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Get intelligent insights, risk analysis, and personalized recommendations for your investment portfolio")
                    .font(.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(.top, 40)
    }
}

#Preview {
    WelcomeHeroSection()
}
