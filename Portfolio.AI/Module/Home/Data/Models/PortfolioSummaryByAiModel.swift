//
//  PortfolioSummaryByAiModel.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 11/9/25.
//

import Foundation

struct PortfolioSummaryByAiModel: Codable, JSONSchemaGeneratable {
    let portfolioSummary: PortfolioSummary?
    let stocks: [Stock]
    let rebalancingPlan: [RebalancingPlan]
    
    enum CodingKeys: String, CodingKey {
        case portfolioSummary = "portfolio_summary"
        case stocks = "stocks"
        case rebalancingPlan = "rebalancing_plan"
    }
    
    init(
        portfolioSummary: PortfolioSummary? = nil,
        stocks: [Stock] = [],
        rebalancingPlan: [RebalancingPlan] = []
    ) {
        self.portfolioSummary = portfolioSummary
        self.stocks = stocks
        self.rebalancingPlan = rebalancingPlan
    }
    
    // MARK: - JSONSchemaGeneratable Implementation
    static func createSampleInstance() -> PortfolioSummaryByAiModel {
        return PortfolioSummaryByAiModel(
            portfolioSummary: PortfolioSummary(
                totalInvested: 0.0,
                currentValue: 0.0,
                pnlPercent: 0.0,
                concentrationRisk: "sample_string",
                diversificationAdvice: "sample_string"
            ),
            stocks: [
                Stock(
                    name: "sample_string",
                    invested: 0.0,
                    fairPriceEstimate: Stock.FairPriceEstimate(
                        minPrice: 0.0,
                        maxPrice: 0.0
                    ),
                    valuation: "sample_string",
                    recommendation: "sample_string",
                    reason: "sample_string",
                    sector: "sample_string"
                )
            ],
            rebalancingPlan: [
                RebalancingPlan(
                    action: "sample_string",
                    stock: "sample_string",
                    rationale: "sample_string",
                    fairEntryRange: RebalancingPlan.FairEntryRange(
                        minPrice: 0.0,
                        maxPrice: 0.0
                    )
                )
            ]
        )
    }
    
    struct PortfolioSummary: Codable {
        let totalInvested: Double
        let currentValue: Double
        let pnlPercent: Double
        let concentrationRisk: String
        let diversificationAdvice: String
        
        enum CodingKeys: String, CodingKey {
            case totalInvested = "total_invested"
            case currentValue = "current_value"
            case pnlPercent = "pnl_percent"
            case concentrationRisk = "concentration_risk"
            case diversificationAdvice = "diversification_advice"
        }
    }
    
    struct Stock: Codable {
        let name: String
        let invested: Double
        let fairPriceEstimate: FairPriceEstimate
        let valuation: String
        let recommendation: String
        let reason: String
        let sector: String
        
        struct FairPriceEstimate: Codable {
            let minPrice: Double
            let maxPrice: Double
            
            enum CodingKeys: String, CodingKey {
                case minPrice = "min_price"
                case maxPrice = "max_price"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case invested
            case fairPriceEstimate = "fair_price_estimate"
            case valuation
            case recommendation
            case reason
            case sector
        }
    }
    
    struct RebalancingPlan: Codable {
        let action: String
        let stock: String
        let rationale: String
        let fairEntryRange: FairEntryRange
        
        enum CodingKeys: String, CodingKey {
            case action
            case stock
            case rationale
            case fairEntryRange = "fair_entry_range"
        }
        
        struct FairEntryRange: Codable {
            let minPrice: Double
            let maxPrice: Double
            
            enum CodingKeys: String, CodingKey {
                case minPrice = "min_price"
                case maxPrice = "max_price"
            }
        }
    }
}
