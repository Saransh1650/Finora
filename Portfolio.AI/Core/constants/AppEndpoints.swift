//
//  app_endpoints.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import Foundation

class AppEndpoints{
    // Portfolio endpoints
    static let portfolio: String = "/portfolio"
    static let latestPortfolio: String = "/portfolio/latest"
    static func portfolioById(id: String) -> String {
        return "/portfolio/\(id)"
    }
    
    // Stock endpoints
    static let stocks: String = "/stocks"
    static let bulkStocks: String = "/stocks/bulk"
    static func stock(id: String) -> String {
        return "/stocks/\(id)"
    }
    
    // Chat conversation endpoints
    static let conversations: String = "/conversations"
    static func conversationById(id: String) -> String {
        return "/conversations/\(id)"
    }
    static func conversationContext(id: String) -> String {
        return "/conversations/\(id)/context"
    }
    
    // Chat message endpoints
    static let messages: String = "/messages"
    static func messageById(id: String) -> String {
        return "/messages/\(id)"
    }
    static func messageAttachments(messageId: String) -> String {
        return "/messages/\(messageId)/attachments"
    }
    static func deleteAttachment(attachmentId: String) -> String {
        return "/messages/attachments/\(attachmentId)"
    }
}
