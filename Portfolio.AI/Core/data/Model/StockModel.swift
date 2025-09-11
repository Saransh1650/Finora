//
//  StockModel.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import Foundation

public struct StockModel: Identifiable, Codable, Hashable {
    public let id: UUID
    var userId: String // Add userId to associate stock with a user
    var name: String
    var symbol: String
    var portfolioPercentage: Double
    var sector: String
    var profitLossPercentage: Double
    var sectorRank: Int
    var avgPrice: Double
    var lastTradingPrice: Double
    
    // CodingKeys to map Swift property names to database column names
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case symbol
        case portfolioPercentage = "portfolio_percentage"
        case sector
        case profitLossPercentage = "profit_loss_percentage"
        case sectorRank = "sector_rank"
        case avgPrice = "avg_price"
        case lastTradingPrice = "last_trading_price"
    }
    
    public init(
        id: UUID = UUID(),
        userId: String,
        name: String,
        symbol: String,
        portfolioPercentage: Double,
        sector: String,
        profitLossPercentage: Double,
        sectorRank: Int,
        avgPrice: Double,
        lastTradingPrice: Double
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.symbol = symbol
        self.portfolioPercentage = portfolioPercentage
        self.sector = sector
        self.profitLossPercentage = profitLossPercentage
        self.sectorRank = sectorRank
        self.avgPrice = avgPrice
        self.lastTradingPrice = lastTradingPrice
    }
    
    public var portfolioFraction: Double {
        return portfolioPercentage / 100.0
    }
    
    public var portfolioPercentageFormatted: String {
        String(format: "%.2f%%", portfolioPercentage)
    }
    
    public var profitLossFormatted: String {
        String(format: "%+.2f%%", profitLossPercentage)
    }
}

// MARK: - Sample Data
#if DEBUG
extension StockModel {
    static let sample1 = StockModel(
        userId: "debug-user-id",
        name: "Apple Inc.",
        symbol: "AAPL",
        portfolioPercentage: 25.00,
        sector: "Technology",
        profitLossPercentage: 12.34,
        sectorRank: 1,
        avgPrice: 150.00,
        lastTradingPrice: 155.00
    )
    static let sample2 = StockModel(
        userId: "debug-user-id",
        name: "Tesla, Inc.",
        symbol: "TSLA",
        portfolioPercentage: 10.50,
        sector: "Automotive",
        profitLossPercentage: -8.42,
        sectorRank: 3,
        avgPrice: 700.00,
        lastTradingPrice: 680.00
    )
    static let samples: [StockModel] = [sample1, sample2]
}
#endif
