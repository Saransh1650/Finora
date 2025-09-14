//
//  FeatureCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.selected.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(AppColors.selected)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.pureBackground)
                .shadow(color: AppColors.divider.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    FeatureCard(
        icon: "chart.line.uptrend.xyaxis",
        title: "Smart Analysis",
        description: "AI analyzes your portfolio performance and market trends"
    )
}
