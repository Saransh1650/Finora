//
//  StockModel.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import Foundation

public struct StockModel: Identifiable, Codable, Hashable {
    public let id: UUID
    var userId: String
    var symbol: String
    var totalInvested: Double
    var quantity: Double

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case symbol
        case totalInvested = "total_invested"
        case quantity
    }

    public init(
        id: UUID = UUID(),
        userId: String,
        symbol: String,
        totalInvested: Double,
        quantity: Double
    ) {
        self.id = id
        self.userId = userId
        self.symbol = symbol
        self.totalInvested = totalInvested
        self.quantity = quantity
    }
}

// MARK: - Sample Data
#if DEBUG
    extension StockModel {
        static let sample1 = StockModel(
            userId: "debug-user-id",
            symbol: "AAPL",
            totalInvested: 1500.00,
            quantity: 10.0
        )
        static let sample2 = StockModel(
            userId: "debug-user-id",
            symbol: "TSLA",
            totalInvested: 2000.00,
            quantity: 5.0
        )
        static let samples: [StockModel] = [sample1, sample2]
    }
#endif
