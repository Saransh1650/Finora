//
//  PortfolioSummaryCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct PortfolioSummaryCard: View {
    let stocks: [StockModel]
    
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
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Portfolio Summary")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("\(stocks.count) holdings ready for analysis")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Ready badge
                ReadyBadge()
            }
            
            // Metrics Grid
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
                    value: "$\(String(format: "%.0f", totalValue))",
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
                    value: "$\(String(format: "%.0f", averageInvestment))",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple,
                    subtitle: "per stock"
                )
            }
            
            // Stock list preview
            if !stocks.isEmpty {
                StockListPreview(stocks: Array(stocks.prefix(3)))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.background)
                .shadow(color: AppColors.textPrimary.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Ready Badge
struct ReadyBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.white)
            
            Text("Ready")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(AppColors.selected)
        )
    }
}

// MARK: - Summary Metric Card
struct SummaryMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.15), color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
            }
            
            // Values
            VStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Stock List Preview
struct StockListPreview: View {
    let stocks: [StockModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Holdings")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if stocks.count < 3 {
                    Text("Showing all")
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                } else {
                    Text("Top 3")
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(stocks.indices, id: \.self) { index in
                    StockPreviewRow(stock: stocks[index], rank: index + 1)
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Stock Preview Row
struct StockPreviewRow: View {
    let stock: StockModel
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(
                    Circle()
                        .fill(AppColors.selected.opacity(0.7))
                )
            
            // Stock symbol
            Text(stock.symbol.uppercased())
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            // Investment amount
            Text("$\(String(format: "%.0f", stock.totalInvested))")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.pureBackground)
        )
    }
}

#Preview {
    PortfolioSummaryCard(stocks: StockModel.samples)
        .padding()
        .background(AppColors.pureBackground)
}
