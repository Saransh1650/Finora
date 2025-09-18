//
//  AddStockButton.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import SwiftUI

struct AddStockButton: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var showingAddDialog = false
    
    var body: some View {
        Button(action: {
            showingAddDialog = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.pureBackground)
                Text("Add Stock")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.pureBackground)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppColors.selected)
            .cornerRadius(25)
            .shadow(color: AppColors.selected.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .fullScreenCover(isPresented: $showingAddDialog) {
            AddStockDialog()
                .background(ClearBackgroundView())
        }
    }
}


#Preview {
    AddStockButton()
}
