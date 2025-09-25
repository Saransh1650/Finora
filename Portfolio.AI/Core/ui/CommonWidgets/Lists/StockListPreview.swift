//
//  StockListPreview.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

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
            Text("\(String(format: "%.0f", stock.totalInvested))")
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
    StockListPreview(stocks: StockModel.samples)
        .padding()
        .background(AppColors.pureBackground)
}
