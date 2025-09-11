import Foundation

struct PortfolioAnalysisModel: Codable {
    let id: UUID?
    let userId: String
    let portfolioSummaryByAiModel: PortfolioSummaryByAiModel?
    let analysisDate: Date?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case portfolioSummaryByAiModel = "portfolio_summary_by_ai_model"
        case analysisDate = "analysis_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(
        id: UUID? = nil,
        userId: String,
        portfolioSummaryByAiModel: PortfolioSummaryByAiModel? = nil,
        analysisDate: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.portfolioSummaryByAiModel = portfolioSummaryByAiModel
        self.analysisDate = analysisDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

}
