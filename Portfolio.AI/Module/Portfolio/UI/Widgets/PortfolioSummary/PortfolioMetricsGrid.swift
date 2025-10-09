//
//  PortfolioMetricsGrid.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct PortfolioMetricsGrid: View {
    let stocks: [StockModel]

    init(
        stocks: [StockModel],
        analysisData: PortfolioSummaryByAiModel.PortfolioSummary? = nil
    ) {
        self.stocks = stocks
    }

    private var totalValue: Double {
        stocks.reduce(0) { $0 + $1.totalInvested }
    }

    private var totalShares: Double {
        stocks.reduce(0) { $0 + $1.quantity }
    }

    private var averageInvestment: Double {
        guard !stocks.isEmpty else { return 0 }
        return totalValue / Double(stocks.count)
    }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 2),
            spacing: 16
        ) {
            SummaryMetricCard(
                title: "Total Stocks",
                value: "\(stocks.count)",
                icon: "chart.pie.fill",
                color: AppColors.selected,
                subtitle: "holdings"
            )

            SummaryMetricCard(
                title: "Total Invested",
                value: "\(String(format: "%.0f", totalValue))",
                icon: "dollarsign.circle.fill",
                color: .green,
                subtitle: "capital"
            )

            SummaryMetricCard(
                title: "Total Shares",
                value: String(format: "%.1f", totalShares),
                icon: "chart.bar.fill",
                color: .orange,
                subtitle: "shares"
            )

            SummaryMetricCard(
                title: "Avg Investment",
                value: "\(String(format: "%.0f", averageInvestment))",
                icon: "chart.line.uptrend.xyaxis",
                color: .purple,
                subtitle: "per stock"
            )

        }
    }
}

#if DEBUG
    #Preview {
        VStack(spacing: 30) {
            // Without analysis data
            PortfolioMetricsGrid(stocks: StockModel.samples)

            // With analysis data
            PortfolioMetricsGrid(
                stocks: StockModel.samples,
                analysisData: PortfolioSummaryByAiModel.PortfolioSummary(
                    concentrationRisk: "Medium risk",
                    diversificationAdvice: "Consider adding more sectors"
                )
            )
        }
        .padding()
        .background(AppColors.pureBackground)
    }
#endif
