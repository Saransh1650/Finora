//
//  PortfolioStatsCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct PortfolioStatsCard: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var portfolioAnalysisManager: PortfolioAnalysisManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Portfolio")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.foreground)
                
                Spacer()
                
                Text("\(portfolioManager.stocks.count) stocks")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.tertiary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatItem(
                    title: "Total Value",
                    value: "₹\(formatCurrency(portfolioAnalysisManager.currentAnalysis?.portfolioSummaryByAiModel?.portfolioSummary?.currentValue ?? 100.0))",
                    icon: "banknote"
                )
                
                StatItem(
                    title: "Total Invested",
                    value: "₹\(formatCurrency(portfolioAnalysisManager.currentAnalysis?.portfolioSummaryByAiModel?.portfolioSummary?.totalInvested ?? 100.0))",
                    icon: "chart.pie"
                )
                
                StatItem(
                    title: "P&L",
                    value: "\(formatPercentage(portfolioAnalysisManager.currentAnalysis?.portfolioSummaryByAiModel?.portfolioSummary?.pnlPercent ?? 0.0))%",
                    icon: portfolioAnalysisManager.currentAnalysis?.portfolioSummaryByAiModel?.portfolioSummary?.pnlPercent ?? 0.0 >= 0 ? "arrow.up.right" : "arrow.down.right",
                    valueColor: portfolioAnalysisManager.currentAnalysis?.portfolioSummaryByAiModel?.portfolioSummary?.pnlPercent ?? 0.0 >= 0 ? .green : .red
                )
                
                StatItem(
                    title: "Sectors",
                    value: "\(Set(portfolioManager.stocks.map { $0.sector }).count)",
                    icon: "building.2"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.pureBackground)
                .shadow(color: AppColors.divider.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Helper Functions
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    private func formatPercentage(_ value: Double) -> String {
        return String(format: "%.1f", value)
    }
}

#Preview {
    PortfolioStatsCard()
        .environmentObject(PortfolioManager())
        .environmentObject(PortfolioAnalysisManager())
}