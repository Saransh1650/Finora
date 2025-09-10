//
//  AIDashboardView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct AIDashboardView: View {
    let analysis: PortfolioAnalysisModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("AI Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.textPrimary)
                }
                .padding(.top)
                
                // Portfolio Summary Card
                if let summary = analysis.portfolioSummary {
                    PortfolioSummaryCard(summary: summary)
                }
                
                // Stock Details Section
                VStack(spacing: 16) {
                    HStack {
                        Text("Stock Details")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ForEach(Array(analysis.stocks.enumerated()), id: \.offset) { index, stock in
                        StockDetailCard(
                            stock: stock,
                            totalPortfolioValue: analysis.portfolioSummary?.currentValue ?? 0
                        )
                    }
                }
                
                // Rebalancing Plan Section
                if !analysis.rebalancingPlan.isEmpty {
                    RebalancingPlanCard(rebalancingPlans: analysis.rebalancingPlan)
                }
                
                // Bottom padding for navigation bar
                Spacer(minLength: 100)
            }
            .padding(.horizontal)
        }
        .background(AppColors.pureBackground)
    }
}

#Preview {
    AIDashboardView(
        analysis: PortfolioAnalysisModel(
            portfolioSummary: PortfolioAnalysisModel.PortfolioSummary(
                totalInvested: 100000,
                currentValue: 105230,
                pnlPercent: 5.23,
                concentrationRisk: "High concentration in Technology sector",
                diversificationAdvice: "Your portfolio shows high concentration in the Technology sector. To mitigate risk and improve diversification, consider rebalancing towards Healthcare and Energy sectors."
            ),
            stocks: [
                PortfolioAnalysisModel.Stock(
                    name: "AAPL",
                    invested: 40000,
                    currentValue: 42000,
                    pnlPercent: 5.0,
                    fairPriceEstimate: PortfolioAnalysisModel.Stock.FairPriceEstimate(
                        minPrice: 160,
                        maxPrice: 175
                    ),
                    valuation: "Overvalued",
                    recommendation: "Reduce",
                    reason: "High concentration and recent price appreciation suggest a trim."
                ),
                PortfolioAnalysisModel.Stock(
                    name: "TSLA",
                    invested: 30000,
                    currentValue: 33000,
                    pnlPercent: 10.0,
                    fairPriceEstimate: PortfolioAnalysisModel.Stock.FairPriceEstimate(
                        minPrice: 280,
                        maxPrice: 310
                    ),
                    valuation: "Fairly Valued",
                    recommendation: "Hold",
                    reason: "Strong growth potential. Current holding is reasonable."
                )
            ],
            rebalancingPlan: [
                PortfolioAnalysisModel.RebalancingPlan(
                    action: "Sell",
                    stock: "AAPL",
                    amount: 10000,
                    rationale: "Reduce tech concentration.",
                    fairEntryRange: PortfolioAnalysisModel.RebalancingPlan.FairEntryRange(
                        minPrice: 160,
                        maxPrice: 175
                    )
                )
            ]
        )
    )
}