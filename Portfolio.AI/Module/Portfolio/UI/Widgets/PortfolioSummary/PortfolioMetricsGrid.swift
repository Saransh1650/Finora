//
//  PortfolioMetricsGrid.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct PortfolioMetricsGrid: View {
    let stocks: [StockModel]
    let analysisData: PortfolioSummaryByAiModel.PortfolioSummary?
    
    init(stocks: [StockModel], analysisData: PortfolioSummaryByAiModel.PortfolioSummary? = nil) {
        self.stocks = stocks
        self.analysisData = analysisData
    }
    
    private var totalValue: Double {
        analysisData?.totalInvested ?? stocks.reduce(0) { $0 + $1.totalInvested }
    }
    
    private var totalShares: Double {
        stocks.reduce(0) { $0 + $1.quantity }
    }
    
    private var averageInvestment: Double {
        guard !stocks.isEmpty else { return 0 }
        return totalValue / Double(stocks.count)
    }
    
    private var currentValue: Double? {
        analysisData?.currentValue
    }
    
    private var hasAnalysisData: Bool {
        analysisData != nil
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
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
            
            if hasAnalysisData, let currentValue = currentValue {
                SummaryMetricCard(
                    title: "Current Value",
                    value: "\(String(format: "%.0f", currentValue))",
                    icon: "chart.line.uptrend.xyaxis",
                    color: currentValue >= totalValue ? .green : .red,
                    subtitle: "market value"
                )
                
                let pnlPercent = analysisData?.pnlPercent ?? 0
                SummaryMetricCard(
                    title: "P&L",
                    value: "\(pnlPercent >= 0 ? "+" : "")\(String(format: "%.1f", pnlPercent))%",
                    icon: pnlPercent >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                    color: pnlPercent >= 0 ? .green : .red,
                    subtitle: "return"
                )
            } else {
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
                totalInvested: 5000,
                currentValue: 5500,
                pnlPercent: 10.0,
                concentrationRisk: "Medium risk",
                diversificationAdvice: "Consider adding more sectors"
            )
        )
    }
    .padding()
    .background(AppColors.pureBackground)
}
#endif
