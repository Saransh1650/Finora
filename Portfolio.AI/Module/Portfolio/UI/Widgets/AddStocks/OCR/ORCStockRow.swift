//
//  ORCStockRow.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/10/25.
//

import SwiftUI

struct OCRStockRow: View {
    let stock: ExtractedStock
    let isSelected: Bool
    @Binding var editableData: EditableStockModel
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Button(action: onToggle) {
                Image(
                    systemName: isSelected ? "checkmark.circle.fill" : "circle"
                )
                .foregroundColor(
                    isSelected ? AppColors.selected : AppColors.textSecondary
                )
                .font(.title3)
            }

            VStack(alignment: .leading, spacing: 8) {
                // Stock symbol and confidence
                HStack {
                    Text(stock.symbol)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    HStack(spacing: 4) {
                        Circle()
                            .fill(
                                Double(stock.confidence) > 0.7
                                    ? .green
                                    : Double(stock.confidence) > 0.5 ? .orange : .red
                            )
                            .frame(width: 6, height: 6)
                        Text("\(Int(stock.confidence * 100))%")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                if isSelected {
                    // Editable fields
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Investment")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                TextField(
                                    "0.00",
                                    text: $editableData.totalInvestment
                                )
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Quantity")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                TextField("0", text: $editableData.quantity)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(
                                        RoundedBorderTextFieldStyle()
                                    )
                            }
                        }

                        // Show calculated average price
                        if let investment = Double(
                            editableData.totalInvestment
                        ),
                            let quantity = Double(editableData.quantity),
                            quantity > 0
                        {
                            HStack {
                                Text("Avg Price:")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(
                                    "\(String(format: "%.2f", investment / quantity))"
                                )
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.selected)
                            }
                        }
                    }
                } else {
                    // Show extracted data (non-editable)
                    HStack(spacing: 16) {
                        if let quantity = stock.quantity {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Qty")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.textSecondary)
                                Text("\(String(format: "%.0f", quantity))")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }

                        if let investment = stock.totalInvestment {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Investment")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.textSecondary)
                                Text("\(String(format: "%.2f", investment))")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }

                        if let avgPrice = stock.avgPrice {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Avg Price")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.textSecondary)
                                Text("\(String(format: "%.2f", avgPrice))")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }

                        Spacer()
                    }
                }
            }
        }
        .padding(12)
        .background(
            isSelected ? AppColors.selected.opacity(0.05) : AppColors.background
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected
                        ? AppColors.selected.opacity(0.3) : AppColors.border,
                    lineWidth: 1
                )
        )
        .cornerRadius(8)
    }
}

