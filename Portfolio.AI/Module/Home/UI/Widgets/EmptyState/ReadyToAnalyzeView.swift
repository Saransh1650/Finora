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

//// MARK: - Error Message View
//struct ErrorMessageView: View {
//    let message: String
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .font(.subheadline)
//                .foregroundColor(.red)
//            
//            Text(message)
//                .font(.caption)
//                .foregroundColor(.red)
//                .multilineTextAlignment(.leading)
//            
//            Spacer()
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.red.opacity(0.1))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
//                )
//        )
//    }
//}

#Preview {
    ReadyToAnalyzeView()
        .environmentObject(PortfolioManager())
        .environmentObject(PortfolioAnalysisManager())
}
