//
//  StockModel.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import Foundation

public struct StockModel: Identifiable, Codable, Hashable {
    public let id: UUID
    var name: String
    var symbol: String
    var portfolioPercentage: Double
    var sector: String
    var profitLossPercentage: Double
    var sectorRank: Int
    var avgPrice: Double
    var lastTradingPrice: Double

    public init(
        id: UUID = UUID(),
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
            name: "Apple Inc.",
            symbol: "AAPL",
            portfolioPercentage: 25.00,
            sector: "Technology",
            profitLossPercentage: 12.34,
            sectorRank: 1,
            avgPrice: 150.00,
            lastTradingPrice: 155.00  // Added missing parameter
        )
        static let sample2 = StockModel(
            name: "Tesla, Inc.",
            symbol: "TSLA",
            portfolioPercentage: 10.50,
            sector: "Automotive",
            profitLossPercentage: -8.42,
            sectorRank: 3,
            avgPrice: 700.00,
            lastTradingPrice: 680.00  // Added missing parameter
        )
        static let samples: [StockModel] = [sample1, sample2]
    }
#endif
