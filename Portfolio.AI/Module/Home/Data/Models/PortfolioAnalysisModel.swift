struct PortfolioAnalysisModel: Decodable {
    let portfolioSummary: PortfolioSummary?
    let stocks: [Stock]
    let rebalancingPlan: [RebalancingPlan]

    enum CodingKeys: String, CodingKey {
        case portfolioSummary = "portfolio_summary"
        case stocks
        case rebalancingPlan = "rebalancing_plan"
    }

    struct PortfolioSummary: Decodable {
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

    struct Stock: Decodable {
        let name: String
        let invested: Double
        let currentValue: Double
        let pnlPercent: Double
        let fairPriceEstimate: FairPriceEstimate
        let valuation: String
        let recommendation: String
        let reason: String

        struct FairPriceEstimate: Decodable {
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
            case currentValue = "current_value"
            case pnlPercent = "pnl_percent"
            case fairPriceEstimate = "fair_price_estimate"
            case valuation
            case recommendation
            case reason
        }

    }

    struct RebalancingPlan: Decodable {
        let action: String
        let stock: String
        let amount: Double
        let rationale: String
        let fairEntryRange: FairEntryRange

        enum CodingKeys: String, CodingKey {
            case action
            case stock
            case amount
            case rationale
            case fairEntryRange = "fair_entry_range"
        }

        struct FairEntryRange: Decodable {
            let minPrice: Double
            let maxPrice: Double

            enum CodingKeys: String, CodingKey {
                case minPrice = "min_price"
                case maxPrice = "max_price"
            }
        }
    }
}
