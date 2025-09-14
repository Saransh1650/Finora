//
//  SummaryMetricCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct SummaryMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.15), color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
            }
            
            // Values
            VStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
        SummaryMetricCard(
            title: "Total Stocks",
            value: "5",
            icon: "chart.pie.fill",
            color: AppColors.selected,
            subtitle: "holdings"
        )
        
        SummaryMetricCard(
            title: "Total Invested",
            value: "$5,000",
            icon: "dollarsign.circle.fill",
            color: .green,
            subtitle: "capital"
        )
    }
    .padding()
    .background(AppColors.pureBackground)
}
