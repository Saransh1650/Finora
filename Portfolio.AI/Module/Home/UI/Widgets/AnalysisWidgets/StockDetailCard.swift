//
//  StockDetailCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct StockDetailCard: View {
    let stock: PortfolioSummaryByAiModel.Stock
    let totalPortfolioValue: Double

    var body: some View {
        VStack(spacing: 12) {
            // Header with stock name and valuation badge
            HStack {
                Text(stock.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                // Valuation badge
                Text(stock.valuation)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(getValuationColor())
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }

            // Stats grid
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    // Allocation
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sector:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Text(stock.sector)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Fair Price Estimate - spans full width
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fair Price Est:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(
                        "₹\(String(format: "%.0f", stock.fairPriceEstimate.minPrice)) - ₹\(String(format: "%.0f", stock.fairPriceEstimate.maxPrice))"
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Analysis section
            VStack(alignment: .leading, spacing: 2) {
                    Text("Analysis:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(stock.reason)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private func formatCurrency(_ amount: Double) -> String {
        return "₹\(String(format: "%.0f", amount))"
    }


    private func getValuationColor() -> Color {
        switch stock.valuation.lowercased() {
        case "overvalued":
            return .red
        case "undervalued":
            return .green
        case "fairly valued", "fair":
            return .blue
        default:
            return .gray
        }
    }
}

#Preview {
    StockDetailCard(
        stock: PortfolioSummaryByAiModel.Stock(
            name: "AAPL",
            invested: 40000,
            fairPriceEstimate: PortfolioSummaryByAiModel.Stock
                .FairPriceEstimate(
                    minPrice: 160,
                    maxPrice: 175
                ),
            valuation: "Overvalued",
            recommendation: "Reduce",
            reason:
                "High concentration and recent price appreciation suggest a trim. The current price is above the fair value estimate.",
            sector: "Technology"
        ),
        totalPortfolioValue: 105230
    )
    .padding()
}
