//
//  BenefitRow.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    
    init(icon: String, title: String, description: String, accentColor: Color = AppColors.selected) {
        self.icon = icon
        self.title = title
        self.description = description
        self.accentColor = accentColor
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced icon container
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                // Subtle inner glow
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        RadialGradient(
                            colors: [accentColor.opacity(0.2), accentColor.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 24
                        )
                    )
                    .frame(width: 48, height: 48) 
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(accentColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Subtle arrow indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.background)
                .shadow(color: AppColors.textPrimary.opacity(0.03), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Benefit Section
struct BenefitsSection: View {
    let title: String
    let benefits: [BenefitItem]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(benefits.indices, id: \.self) { index in
                    BenefitRow(
                        icon: benefits[index].icon,
                        title: benefits[index].title,
                        description: benefits[index].description,
                        accentColor: benefits[index].accentColor
                    )
                }
            }
        }
    }
}

// MARK: - Benefit Item Model
struct BenefitItem {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    
    init(icon: String, title: String, description: String, accentColor: Color = AppColors.selected) {
        self.icon = icon
        self.title = title
        self.description = description
        self.accentColor = accentColor
    }
}

// MARK: - Predefined Benefits
extension BenefitItem {
    static let portfolioBenefits = [
        BenefitItem(
            icon: "chart.line.uptrend.xyaxis",
            title: "Better Analysis",
            description: "More data points for accurate insights and trends",
            accentColor: AppColors.selected
        ),
        BenefitItem(
            icon: "shield.checkered",
            title: "Risk Assessment",
            description: "Identify diversification opportunities and risks",
            accentColor: .orange
        ),
        BenefitItem(
            icon: "lightbulb.fill",
            title: "Smart Recommendations",
            description: "AI-powered portfolio optimization suggestions",
            accentColor: .yellow
        )
    ]
    
    static let analysisBenefits = [
        BenefitItem(
            icon: "chart.bar.fill",
            title: "Performance Analysis",
            description: "Detailed breakdown of your portfolio performance",
            accentColor: AppColors.selected
        ),
        BenefitItem(
            icon: "shield.lefthalf.filled",
            title: "Risk Assessment",
            description: "Understand your portfolio's risk profile",
            accentColor: .orange
        ),
        BenefitItem(
            icon: "lightbulb.fill",
            title: "AI Recommendations",
            description: "Personalized suggestions for optimization",
            accentColor: .yellow
        ),
        BenefitItem(
            icon: "chart.pie.fill",
            title: "Diversification Insights",
            description: "See how well-diversified your holdings are",
            accentColor: .green
        )
    ]
}

#Preview {
    VStack(spacing: 20) {
        BenefitsSection(title: "Why Add More Stocks?", benefits: BenefitItem.portfolioBenefits)
        BenefitsSection(title: "What You'll Get", benefits: BenefitItem.analysisBenefits)
    }
    .padding()
    .background(AppColors.pureBackground)
}
