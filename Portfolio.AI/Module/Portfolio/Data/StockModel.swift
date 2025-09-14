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
    var totalInvestment: Double
    var noOfShares: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case symbol
        case totalInvestment = "total_investment"
        case noOfShares = "no_of_shares"
    }
    
    public init(
        id: UUID = UUID(),
        userId: String,
        symbol: String,
        totalInvestment: Double ,
        noOfShares: Double
    ) {
        self.id = id
        self.userId = userId
        self.symbol = symbol
        self.totalInvestment = totalInvestment
        self.noOfShares = noOfShares
    }
}

// MARK: - Sample Data
#if DEBUG
extension StockModel {
    static let sample1 = StockModel(
        userId: "debug-user-id",
        symbol: "AAPL",
        totalInvestment: 1500.00,
        noOfShares: 10.0
    )
    static let sample2 = StockModel(
        userId: "debug-user-id",
        symbol: "TSLA",
        totalInvestment: 2000.00,
        noOfShares: 5.0
    )
    static let samples: [StockModel] = [sample1, sample2]
}
#endif
