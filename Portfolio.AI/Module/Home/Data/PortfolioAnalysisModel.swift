//
//  PortfolioAnalysisModel.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 7/9/25.
//

import Foundation

struct PortfolioSummary: Codable {
    let totalInvested: Double
    let currentValue: Double
    let pnlPercent: Double
    let concentrationRisk: String
    let diversificationAdvice: String
}

struct FairPriceEstimate: Codable {
    let minPrice: Double
    let maxPrice: Double
}

struct Stock: Codable {
    let name: String
    let invested: Double
    let currentValue: Double
    let pnlPercent: Double
    let fairPriceEstimate: FairPriceEstimate
    let valuation: Valuation
    let recommendation: Recommendation
    let reason: String
}

enum Valuation: String, Codable {
    case undervalued = "Undervalued"
    case fairlyValued = "Fairly Valued"
    case overvalued = "Overvalued"
}

enum Recommendation: String, Codable {
    case add = "Add"
    case hold = "Hold"
    case reduce = "Reduce"
    case exit = "Exit"
}

struct FairEntryRange: Codable {
    let minPrice: Double
    let maxPrice: Double
}

struct RebalancingPlan: Codable {
    let action: Action
    let stock: String
    let amount: Double
    let rationale: String
    let fairEntryRange: FairEntryRange
}

enum Action: String, Codable {
    case sell = "Sell"
    case buy = "Buy"
    case hold = "Hold"
}

struct PortfolioAnalysisModel: Codable {
    let portfolioSummary: PortfolioSummary
    let stocks: [Stock]
    let rebalancingPlan: [RebalancingPlan]
}
