//
//  HeaderWithAnalysisButton.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct HeaderWithAnalysisButton: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var portfolioAnalysisManager: PortfolioAnalysisManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.textPrimary)

                if let lastAnalysis = portfolioAnalysisManager.currentAnalysis
                    ?? portfolioAnalysisManager.analysisHistory.first,
                    let date = lastAnalysis.analysisDate
                {
                    Text("Last updated: \(date, style: .relative)")
                        .font(.caption)
                }
            }

            Spacer()

            //Analysis Button
            Button {
                Task {
                    await portfolioAnalysisManager.generateSummaryAndSave(
                        stocks: portfolioManager.stocks
                    )
                }
            } label: {
                HStack(spacing: 8) {
                    if portfolioAnalysisManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: AppColors.pureBackground)
                            )
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.pureBackground)
                    }

                    Text(
                        portfolioAnalysisManager.isLoading
                            ? "Analyzing..." : "Refresh"
                    )
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.pureBackground)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [
                            AppColors.selected, AppColors.selected.opacity(0.8),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(
                    color: AppColors.selected.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .disabled(portfolioAnalysisManager.isLoading)
            .scaleEffect(portfolioAnalysisManager.isLoading ? 0.95 : 1.0)
            .animation(
                .easeInOut(duration: 0.2),
                value: portfolioAnalysisManager.isLoading
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.pureBackground)
                .stroke(AppColors.border, lineWidth: 1)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
               
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

#Preview {
    HeaderWithAnalysisButton()
        .environmentObject(PortfolioManager())
        .environmentObject(PortfolioAnalysisManager())
}
