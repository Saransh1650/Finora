//
//  AddStockDialog.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import SwiftUI

struct AddStockDialog: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var portfolioManager: PortfolioManager

    @State private var stockSymbol: String = ""
    @State private var totalInvestment: String = ""
    @State private var quantity: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            // Background overlay
            AppColors.background.opacity(0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Dialog content
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Add Stock")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Enter your stock details")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }

                // Form Fields
                VStack(spacing: 16) {
                    AppTextField(
                        title: "Stock Symbol",
                        placeholder: "AAPL",
                        text: $stockSymbol
                    )
                    .autocapitalization(.allCharacters)

                    AppTextField(
                        title: "Total Investment",
                        placeholder: "0.00",
                        text: $totalInvestment,
                        keyboardType: .decimalPad,
                        prefix: "$"
                    )

                    AppTextField(
                        title: "Number of Shares",
                        placeholder: "0",
                        text: $quantity,
                        keyboardType: .decimalPad
                    )

                    // Show calculated average price if both fields are filled
                    if !totalInvestment.isEmpty && !quantity.isEmpty,
                        let investment = Double(totalInvestment),
                        let shares = Double(quantity),
                        shares > 0
                    {
                        HStack {
                            Text("Avg Price:")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(
                                "$\(String(format: "%.2f", investment / shares))"
                            )
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.selected)
                        }
                        .padding(.horizontal, 4)
                    }
                }

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                // Action Buttons
                HStack(spacing: 12) {
                    // Cancel Button
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.background)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.border, lineWidth: 1)
                    )

                    // Add Button
                    Button(action: addStock) {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint: .white)
                                    )
                                    .scaleEffect(0.8)
                            } else {
                                Text("Add Stock")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        isFormValid && !isLoading
                            ? AppColors.selected : AppColors.textSecondary
                    )
                    .cornerRadius(8)
                    .disabled(!isFormValid || isLoading)
                }
            }
            .padding(24)
            .background(AppColors.background)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
            .padding(.horizontal, 32)
        }
    }

    private var isFormValid: Bool {
        !stockSymbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !totalInvestment.isEmpty && Double(totalInvestment) != nil
            && Double(totalInvestment) ?? 0 > 0 && !quantity.isEmpty
            && Double(quantity) != nil && Double(quantity) ?? 0 > 0
    }

    private func addStock() {
        guard isFormValid else { return }

        guard let investment = Double(totalInvestment),
            let shares = Double(quantity)
        else {
            errorMessage = "Please enter valid numbers"
            return
        }

        guard
            let userId = SupabaseManager.shared.client.auth.currentUser?.id
                .uuidString
        else {
            errorMessage = "User not authenticated. Please log in again."
            return
        }

        isLoading = true
        errorMessage = nil

        // Create the new stock
        let newStock = StockModel(
            userId: userId,
            symbol: stockSymbol.uppercased().trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            totalInvested: investment,
            quantity: shares
        )

        // Add to portfolio
        Task {
            await portfolioManager.addStock([newStock])
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    AddStockDialog()
}
