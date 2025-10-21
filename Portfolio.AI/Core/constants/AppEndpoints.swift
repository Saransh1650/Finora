//
//  app_endpoints.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import Foundation

class AppEndpoints{
    static let portfolio: String = "/portfolio"
    static let latestPortfolio: String = "/portfolio/latest"
    static func portfolioById(id: String) -> String {
        return "/portfolio/\(id)"
    }
    static let stocks: String = "/stocks"
    static let bulkStocks: String = "/stocks/bulk"
    static func stock(id: String) -> String {
        return "/stocks/\(id)"
    }
    static func conversation(page: Int, limit: Int) -> String {
        return "conversations?page=\(page)&limit=\(limit)"
    }
}
