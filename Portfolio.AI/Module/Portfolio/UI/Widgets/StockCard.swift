//
//  StockCard.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import SwiftUI

struct StockCard: View {
    let stock: StockModel
    
    // Calculate additional metrics
    private var averagePrice: Double {
        guard stock.quantity > 0 else { return 0 }
        return stock.totalInvested / stock.quantity
    }
    
    private var formattedInvestment: String {
        return String(format: "$%.2f", stock.totalInvested)
    }
    
    private var formattedShares: String {
        if stock.quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", stock.quantity)
        } else {
            return String(format: "%.2f", stock.quantity)
        }
    }
    
    private var formattedAvgPrice: String {
        return String(format: "$%.2f", averagePrice)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Stock Symbol Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.selected.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Text(symbolShort)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.selected)
                }
                
                // Stock Information
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(stock.symbol.uppercased())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text(formattedInvestment)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Shares")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Text(formattedShares)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Avg Price")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Text(formattedAvgPrice)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(16)
        }
        .background(AppColors.background)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: AppColors.textPrimary.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var symbolShort: String {
        let s = stock.symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(s.prefix(3)).uppercased()
    }
}

#Preview {
    StockCard(stock: StockModel.sample1)
}
