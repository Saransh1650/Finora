//
//  AIOverviewCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct AIOverviewCard: View {
    let portfolioSummary: PortfolioSummaryByAiModel.PortfolioSummary
    
    var body: some View {
        VStack(alignment: .leading) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Portfolio Overview")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Performance & Risk Analysis")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
            }
            .padding(.bottom, 12)
            Text(portfolioSummary.concentrationRisk)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            Text(portfolioSummary.diversificationAdvice)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
            
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.background)
                .shadow(color: AppColors.textPrimary.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    AIOverviewCard(
        portfolioSummary: PortfolioSummaryByAiModel.PortfolioSummary(
            totalInvested: 100000,
            currentValue: 105230,
            pnlPercent: 5.23,
            concentrationRisk: "High concentration in Technology sector",
            diversificationAdvice: "Consider rebalancing towards Healthcare and Energy sectors."
        )
    )
    .padding()
    .background(AppColors.pureBackground)
}
