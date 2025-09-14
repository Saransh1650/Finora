//
//  MinimumStocksRequiredView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct MinimumStocksRequiredView: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header with animated icon
                EmptyStateHeader(
                    iconName: "chart.pie.fill",
                    title: "Build Your Portfolio",
                    subtitle: "Add at least 2 stocks to start analyzing your portfolio",
                    style: .default
                )
                
                // Portfolio progress section
                VStack(spacing: 16) {
                    HStack {
                        Text("Current Portfolio")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                    }
                    
                    PortfolioStatusCard(
                        currentStocks: portfolioManager.stocks.count,
                        requiredStocks: 2
                    )
                }
                .padding(.horizontal, 20)
                
                // Benefits section
                BenefitsSection(
                    title: "Why Add More Stocks?",
                    benefits: BenefitItem.portfolioBenefits
                )
                .padding(.horizontal, 20)
                
                // Call to action section
                VStack(spacing: 16) {
                    AddStockActionButton(
                        buttonText: "Add Your Next Stock",
                        style: .primary
                    )
                    
                    // Encouragement message
                    if portfolioManager.stocks.count == 1 {
                        EncouragementMessage(
                            text: "Just 1 more stock needed!",
                            icon: "star.fill"
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppColors.pureBackground)
    }
}

// MARK: - Encouragement Message
struct EncouragementMessage: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(AppColors.selected)
            
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.selected)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.selected.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.selected.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: text)
    }
}

#Preview {
    MinimumStocksRequiredView()
        .environmentObject(PortfolioManager())
}

#Preview {
    MinimumStocksRequiredView()
        .environmentObject(PortfolioManager())
}
