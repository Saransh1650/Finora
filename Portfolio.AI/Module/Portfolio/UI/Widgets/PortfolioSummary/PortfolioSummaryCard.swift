//
//  PortfolioSummaryCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct PortfolioSummaryCard: View {
    let stocks: [StockModel]
    let analysisData: PortfolioSummaryByAiModel.PortfolioSummary?

    @State private var isExpanded: Bool = false

    init(
        stocks: [StockModel],
        analysisData: PortfolioSummaryByAiModel.PortfolioSummary? = nil
    ) {
        self.stocks = stocks
        self.analysisData = analysisData
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header - Always visible and tappable
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                CollapsiblePortfolioHeader(
                    stockCount: stocks.count,
                    isReady: stocks.count >= 2,
                    isExpanded: isExpanded
                )
                .padding(24)
            }
            .buttonStyle(PlainButtonStyle())

            // Expandable content
            if isExpanded {
                VStack(spacing: 20) {
                    // Metrics Grid
                    PortfolioMetricsGrid(
                        stocks: stocks,
                        analysisData: analysisData
                    )

                    // Stock list preview
                    if !stocks.isEmpty {
                        StockListPreview(stocks: Array(stocks.prefix(3)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    )
                )
            }

        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.background)
                .shadow(
                    color: AppColors.textPrimary.opacity(0.08),
                    radius: 12,
                    x: 0,
                    y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
        .clipped()
    }

}
#if DEBUG
#Preview {
    VStack(spacing: 20) {
        PortfolioSummaryCard(stocks: StockModel.samples)
        
        PortfolioSummaryCard(
            stocks: StockModel.samples,
            analysisData: PortfolioSummaryByAiModel.PortfolioSummary(
                totalInvested: 5000,
                currentValue: 5500,
                pnlPercent: 10.0,
                concentrationRisk: "Medium risk",
                diversificationAdvice: "Consider diversification"
            )
        )
    }
    .padding()
    .background(AppColors.pureBackground)
}
#endif
