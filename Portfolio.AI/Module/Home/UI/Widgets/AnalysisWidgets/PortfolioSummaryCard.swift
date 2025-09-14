//
//  PortfolioSummaryCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct PortfolioSummaryCard: View {
    let summary: PortfolioSummaryByAiModel.PortfolioSummary
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Portfolio Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
            }
            
            // Main stats grid
            VStack(spacing: 16) {
                // Top row - Value and P&L
                HStack(spacing: 16) {
                    // Total Value
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Value")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(summary.currentValue))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Overall P&L
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Overall P&L")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Text(formatPnL(summary.currentValue - summary.totalInvested))
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("(\(String(format: "%.2f", summary.pnlPercent))%)")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(summary.pnlPercent >= 0 ? .green : .red)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Bottom row - Risk and Diversification
                HStack(spacing: 16) {
                    // Risk Level
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Risk Level")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(getRiskLevel())
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(getRiskColor())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Diversification
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Diversification")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(getDiversificationLevel())
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(getDiversificationColor())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // AI Recommendation
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Recommendation")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text(summary.diversificationAdvice)
                        .font(.caption)
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.foreground)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return "₹\(String(format: "%.0f", amount))"
    }
    
    private func formatPnL(_ amount: Double) -> String {
        let prefix = amount >= 0 ? "+" : ""
        return "\(prefix)₹\(String(format: "%.0f", amount))"
    }
    
    private func getRiskLevel() -> String {
        if summary.concentrationRisk.lowercased().contains("high") {
            return "High"
        } else if summary.concentrationRisk.lowercased().contains("medium") {
            return "Medium"
        } else {
            return "Low"
        }
    }
    
    private func getRiskColor() -> Color {
        switch getRiskLevel() {
        case "High": return .red
        case "Medium": return .orange
        default: return .green
        }
    }
    
    private func getDiversificationLevel() -> String {
        if summary.diversificationAdvice.lowercased().contains("poor") ||
           summary.diversificationAdvice.lowercased().contains("low") {
            return "Poor"
        } else if summary.diversificationAdvice.lowercased().contains("moderate") {
            return "Moderate"
        } else {
            return "Good"
        }
    }
    
    private func getDiversificationColor() -> Color {
        switch getDiversificationLevel() {
        case "Poor": return .red
        case "Moderate": return .orange
        default: return .green
        }
    }
}

#Preview {
    PortfolioSummaryCard(
        summary: PortfolioSummaryByAiModel.PortfolioSummary(
            totalInvested: 100000,
            currentValue: 105230,
            pnlPercent: 5.23,
            concentrationRisk: "High concentration in Technology sector",
            diversificationAdvice: "Your portfolio shows high concentration in the Technology sector. To mitigate risk and improve diversification, consider rebalancing towards Healthcare and Energy sectors."
        )
    )
    .padding()
}
