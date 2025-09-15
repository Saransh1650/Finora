//
//  RebalancingPlanCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct RebalancingPlanCard: View {
    let rebalancingPlans: [PortfolioSummaryByAiModel.RebalancingPlan]

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Rebalancing Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
            }

            // Plan items
            VStack(spacing: 16) {
                ForEach(Array(rebalancingPlans.enumerated()), id: \.offset) {
                    index,
                    plan in
                    RebalancingPlanItem(plan: plan)
                }
            }

            Button(
                action: {
                }) {
                    Text("Ask more with AI-Chat")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.pureBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.selected.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            Text("Coming Soon")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.foreground)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

}

struct RebalancingPlanItem: View {
    let plan: PortfolioSummaryByAiModel.RebalancingPlan

    var body: some View {
        VStack(spacing: 8) {
            // Action header
            HStack {
                Text(getActionText())
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text(getAmountText())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(getAmountColor())
            }

            // Fair entry range (for buy actions)
            if plan.action.lowercased() == "buy" {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)

                    Text("Fair Entry Range:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(
                        "₹\(String(format: "%.0f", plan.fairEntryRange.minPrice)) - ₹\(String(format: "%.0f", plan.fairEntryRange.maxPrice))"
                    )
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Rationale
            HStack {
                Text(plan.rationale)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
        }
        .padding(.vertical, 8)
    }

    private func getActionText() -> String {
        return "\(plan.action) \(plan.stock)"
    }

    private func getAmountText() -> String {
        switch plan.action.lowercased() {
        case "sell":
            return "-₹\(String(format: "%.0f", plan.amount))"
        case "buy":
            return "+₹\(String(format: "%.0f", plan.amount))"
        default:
            return "No Change"
        }
    }

    private func getAmountColor() -> Color {
        switch plan.action.lowercased() {
        case "sell":
            return .red
        case "buy":
            return .green
        default:
            return .secondary
        }
    }
}

#Preview {
    RebalancingPlanCard(
        rebalancingPlans: [
            PortfolioSummaryByAiModel.RebalancingPlan(
                action: "Sell",
                stock: "AAPL",
                amount: 10000,
                rationale:
                    "Reduce allocation from 39.9% to ~30% to decrease tech concentration.",
                fairEntryRange: PortfolioSummaryByAiModel.RebalancingPlan
                    .FairEntryRange(
                        minPrice: 160,
                        maxPrice: 175
                    )
            ),
            PortfolioSummaryByAiModel.RebalancingPlan(
                action: "Buy",
                stock: "JNJ",
                amount: 15000,
                rationale:
                    "Increase Healthcare exposure. Current price is attractive for entry.",
                fairEntryRange: PortfolioSummaryByAiModel.RebalancingPlan
                    .FairEntryRange(
                        minPrice: 155,
                        maxPrice: 165
                    )
            ),
            PortfolioSummaryByAiModel.RebalancingPlan(
                action: "Hold",
                stock: "TSLA",
                amount: 0,
                rationale:
                    "Maintain current position as it aligns with the strategy.",
                fairEntryRange: PortfolioSummaryByAiModel.RebalancingPlan
                    .FairEntryRange(
                        minPrice: 280,
                        maxPrice: 310
                    )
            ),
        ]
    )
    .padding()
}
