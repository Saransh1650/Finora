//
//  CollapsableContainer.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct CollapsiblePortfolioHeader: View {
    let stockCount: Int
    let isReady: Bool
    let isExpanded: Bool
    
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
            
            HStack(spacing: 12) {
                // Status badge
                if isReady {
                    StatusBadge.ready()
                } else {
                    StatusBadge.pending("Building")
                }
                
                // Expand/collapse chevron
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textSecondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
            }
        }
        .contentShape(Rectangle())
    }
    }
