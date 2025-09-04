//
//  StockCard.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import SwiftUI

struct StockCard: View {
    let stock: StockModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon / symbol circle
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 56, height: 56)
                Text(symbolShort)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            // Main text
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(stock.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(stock.portfolioPercentageFormatted)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(stock.sector)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(stock.profitLossFormatted)
                        .font(.subheadline)
                        .foregroundColor(stock.profitLossPercentage >= 0 ? .green : .red)
                }
            }
        }
        .padding(.vertical, 8)
        
        //        .overlay(
        //            // sector rank badge
        //            HStack {
        //                Spacer()
        //                VStack {
        //                    Text("#\(stock.sectorRank)")
        //                        .font(.caption2)
        //                        .padding(.horizontal, 8)
        //                        .padding(.vertical, 4)
        //                        .background(Color(.systemGray5))
        //                        .clipShape(Capsule())
        //                    Spacer()
        //                }
        //            }
        //        )
    }
    
    private var symbolShort: String {
        let s = stock.symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(s.prefix(3)).uppercased()
    }
}


#Preview {
    StockCard(stock: StockModel.sample1)
}
