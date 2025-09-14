//
//  PortfolioSummryHeader.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct PortfolioSummaryHeader: View {
    let stockCount: Int
    let isReady: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Portfolio Summary")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(stockCount) holdings \(isReady ? "ready for analysis" : "added")")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Status badge
            if isReady {
                StatusBadge.ready()
            } else {
                StatusBadge.pending("Building")
            }
        }
    }
}

