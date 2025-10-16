//
//  AddStockMethodDialog.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/10/25.
//

import SwiftUI

enum AddStockMethod {
    case ocr
    case manual
}

struct AddStockMethodDialog: View {
    @Environment(\.dismiss) private var dismiss
    let onMethodSelected: (AddStockMethod) -> Void

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
                    Text("Add Stocks")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Choose how you'd like to add stocks")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Method options
                VStack(spacing: 12) {
                    // OCR Method
                    Button(action: {
                        onMethodSelected(.ocr)
                        dismiss()
                    }) {
                        HStack(spacing: 16) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(AppColors.selected.opacity(0.1))
                                    .frame(width: 48, height: 48)

                                Image(systemName: "doc.text.viewfinder")
                                    .foregroundColor(AppColors.selected)
                                    .font(.title3)
                            }

                            // Content
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Screenshot Scan")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textPrimary)

                                    HStack {
                                        Image(systemName: "bolt.fill")
                                            .padding(.trailing, -4)
                                        Text("FASTER")
                                    }
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(AppColors.textSecondary)
                                    .cornerRadius(4)
                                }

                                Text(
                                    "Upload a screenshot of your portfolio and let AI extract the stock data"
                                )
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.leading)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.caption)
                        }
                        .padding(16)
                        .background(AppColors.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    AppColors.selected.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Manual Method
                    Button(action: {
                        onMethodSelected(.manual)
                        dismiss()
                    }) {
                        HStack(spacing: 16) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(AppColors.textSecondary.opacity(0.1))
                                    .frame(width: 48, height: 48)

                                Image(systemName: "keyboard")
                                    .foregroundColor(AppColors.textSecondary)
                                    .font(.title3)
                            }

                            // Content
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Manual Entry")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                Text("Enter stock details manually one by one")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.caption)
                        }
                        .padding(16)
                        .background(AppColors.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

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
            }
            .padding(24)
            .background(AppColors.background)
            .border(AppColors.border, width: 1)
            .cornerRadius(16)
            .shadow(
                color: AppColors.textPrimary.opacity(0.1),
                radius: 20,
                x: 0,
                y: 8
            )
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    AddStockMethodDialog { method in
        print("Selected method: \(method)")
    }
}
