//
//  StatItem.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let valueColor: Color
    
    init(title: String, value: String, icon: String, valueColor: Color = AppColors.foreground) {
        self.title = title
        self.value = value
        self.icon = icon
        self.valueColor = valueColor
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.selected)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(valueColor)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(AppColors.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.background)
        )
    }
}

#Preview {
    StatItem(
        title: "Total Value",
        value: "₹1,00,000",
        icon: "banknote"
    )
}