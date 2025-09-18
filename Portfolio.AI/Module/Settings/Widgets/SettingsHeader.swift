//
//  SettingsHeader.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 16/9/25.
//

import SwiftUI

struct SettingsHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            // App Icon
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [AppColors.background, AppColors.pureBackground.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                )
            
            VStack(spacing: 4) {
                Text("Finora")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Smart Investment Management")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 8)
    }
}

