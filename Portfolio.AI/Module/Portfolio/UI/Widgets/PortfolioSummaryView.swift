//
//  PortfolioSummaryView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import SwiftUI

struct PortfolioSummaryView: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Portfolio Value")
                        .font(.subheadline)
                        .foregroundColor(AppColors.tertiary)
                    
                    Text(totalValue.formatted(.currency(code: "USD")))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.foreground)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Return")
                        .font(.subheadline)
                        .foregroundColor(AppColors.tertiary)
                    
                    HStack(spacing: 4) {
                        Text(totalReturn.formatted(.currency(code: "USD")))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(profitLossPercentage)
                            .font(.subheadline)
                            .foregroundColor(totalReturn >= 0 ? .green : .red)
                    }
                }
            }
            
            Divider()
                .background(AppColors.divider)
            
            HStack {
                ForEach(topSectors, id: \.0) { sector, percentage in
                    VStack(spacing: 4) {
                        Text(sector)
                            .font(.caption)
                            .foregroundColor(AppColors.tertiary)
                        
                        Text(String(format: "%.1f%%", percentage))
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.foreground)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(AppColors.background)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // Computed properties for portfolio statistics
    private var totalValue: Double {
        portfolioManager.stocks.reduce(0) { $0 + ($1.lastTradingPrice) }
    }
    
    private var totalReturn: Double {
        portfolioManager.stocks.reduce(0) { $0 + ($1.lastTradingPrice - $1.avgPrice) }
    }
    
    private var profitLossPercentage: String {
        let totalInvestment = portfolioManager.stocks.reduce(0) { $0 + $1.avgPrice }
        guard totalInvestment > 0 else { return "+0.00%" }
        
        let percentage = (totalReturn / totalInvestment) * 100
        return String(format: "%+.2f%%", percentage)
    }
    
    private var topSectors: [(String, Double)] {
        // Group stocks by sector and calculate percentage
        let sectorGroups = Dictionary(grouping: portfolioManager.stocks) { $0.sector }
        
        // Calculate percentage for each sector
        var sectorPercentages: [(String, Double)] = []
        
        for (sector, stocks) in sectorGroups {
            let sectorValue = stocks.reduce(0) { $0 + $1.lastTradingPrice }
            let percentage = (sectorValue / totalValue) * 100
            sectorPercentages.append((sector, percentage))
        }
        
        // Sort by percentage and get top 3
        return sectorPercentages
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { ($0.0, $0.1) }
    }
}

#Preview {
    PortfolioSummaryView()
        .padding()
}
