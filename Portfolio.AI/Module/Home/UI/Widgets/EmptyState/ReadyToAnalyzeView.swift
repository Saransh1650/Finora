//
//  ReadyToAnalyzeView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct ReadyToAnalyzeView: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var portfolioAnalysisManager: PortfolioAnalysisManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Success header
                SuccessStateHeader(
                    title: "Portfolio Ready!",
                    subtitle: "You have \(portfolioManager.stocks.count) stocks in your portfolio. Start analyzing to get insights!",
                    badgeText: "Ready to Analyze"
                )
                
                // Enhanced portfolio summary
                PortfolioSummaryCard(stocks: portfolioManager.stocks)
                    .padding(.horizontal, 20)
                
                // Analysis benefits
                BenefitsSection(
                    title: "What You'll Get",
                    benefits: BenefitItem.analysisBenefits
                )
                .padding(.horizontal, 20)
                
                // Analysis action section
                VStack(spacing: 16) {
                    if portfolioAnalysisManager.isLoading {
                        AnalyzingLoadingView()
                    } else {
                        StartAnalysisButton()
                    }
                    
                    // Error handling
                    if let errorMessage = portfolioAnalysisManager.errorMessage {
                        ErrorMessageView(errorMessage: errorMessage)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppColors.pureBackground)
    }
}

#Preview {
    ReadyToAnalyzeView()
        .environmentObject(PortfolioManager())
        .environmentObject(PortfolioAnalysisManager())
}
