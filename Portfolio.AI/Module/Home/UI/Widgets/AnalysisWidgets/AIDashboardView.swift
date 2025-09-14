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
                // Portfolio Summary Card
                if let summary = analysis.portfolioSummaryByAiModel?
                    .portfolioSummary
                {
                    PortfolioSummaryCard(summary: summary)
                }

                // Stock Details Section
                if let stocks = analysis.portfolioSummaryByAiModel?.stocks,
                    !stocks.isEmpty
                {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Stock Details")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal)

                        ForEach(Array(stocks.enumerated()), id: \.offset) {
                            index,
                            stock in
                            StockDetailCard(
                                stock: stock,
                                totalPortfolioValue: analysis
                                    .portfolioSummaryByAiModel?
                                    .portfolioSummary?
                                    .currentValue ?? 0
                            )
                        }
                    }
                }

                // Rebalancing Plan Section
                if let rebalancingPlan = analysis.portfolioSummaryByAiModel?
                    .rebalancingPlan, !rebalancingPlan.isEmpty
                {
                    RebalancingPlanCard(
                        rebalancingPlans: rebalancingPlan
                    )
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
            userId: "String",
            portfolioSummaryByAiModel: PortfolioSummaryByAiModel(
                portfolioSummary: PortfolioSummaryByAiModel.PortfolioSummary(
                    totalInvested: 100000,
                    currentValue: 105230,
                    pnlPercent: 5.23,
                    concentrationRisk:
                        "High concentration in Technology sector",
                    diversificationAdvice:
                        "Your portfolio shows high concentration in the Technology sector. To mitigate risk and improve diversification, consider rebalancing towards Healthcare and Energy sectors."
                ),
                stocks: [
                    PortfolioSummaryByAiModel.Stock(
                        name: "AAPL",
                        invested: 40000,
                        currentValue: 42000,
                        pnlPercent: 5.0,
                        fairPriceEstimate: PortfolioSummaryByAiModel.Stock
                            .FairPriceEstimate(
                                minPrice: 160,
                                maxPrice: 175
                            ),
                        valuation: "Overvalued",
                        recommendation: "Reduce",
                        reason:
                            "High concentration and recent price appreciation suggest a trim."
                    ),
                    PortfolioSummaryByAiModel.Stock(
                        name: "TSLA",
                        invested: 30000,
                        currentValue: 33000,
                        pnlPercent: 10.0,
                        fairPriceEstimate: PortfolioSummaryByAiModel.Stock
                            .FairPriceEstimate(
                                minPrice: 280,
                                maxPrice: 310
                            ),
                        valuation: "Fairly Valued",
                        recommendation: "Hold",
                        reason:
                            "Strong growth potential. Current holding is reasonable."
                    ),
                ],
                rebalancingPlan: [
                    PortfolioSummaryByAiModel.RebalancingPlan(
                        action: "Sell",
                        stock: "AAPL",
                        amount: 10000,
                        rationale: "Reduce tech concentration.",
                        fairEntryRange: PortfolioSummaryByAiModel
                            .RebalancingPlan
                            .FairEntryRange(
                                minPrice: 160,
                                maxPrice: 175
                            )
                    )
                ]
            )
        )
    )
}
