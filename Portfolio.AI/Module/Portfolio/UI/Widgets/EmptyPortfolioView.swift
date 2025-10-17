//
//  EmptyPortfolioView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import SwiftUI

struct EmptyPortfolioView: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @Binding var showManualDialog: Bool
    @Binding var showOCRDialog: Bool

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.selected.opacity(0.3))

                VStack(spacing: 8) {
                    Text("Your Portfolio is Empty")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(
                        "Start building your investment portfolio by adding your first stock"
                    )
                    .font(.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                }
            }

            AddStockButton(
                showManualDialog: $showManualDialog,
                showOCRDialog: $showOCRDialog
            )
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.pureBackground)
    }
}

#Preview {
    EmptyPortfolioView(
        showManualDialog: .constant(false),
        showOCRDialog: .constant(false)
    )
}
