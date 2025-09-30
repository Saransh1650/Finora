//
//  ChatConversation.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import Foundation

// MARK: - Enums

enum ContextType: String, Codable, CaseIterable {
    case general
    case portfolio
    case stockAnalysis = "stock_analysis"
    case marketInsights = "market_insights"
}

enum SessionType: String, Codable, CaseIterable {
    case chat
    case analysis
    case planning
    case research
}

// MARK: - Support Models

struct LastAnalysisInfo: Codable {
    let id: UUID
    let analysisDate: Date
    let summary: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case analysisDate = "analysis_date"
        case summary
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        analysisDate = try container.decode(Date.self, forKey: .analysisDate)
        
        // Handle Any type for summary
        if let summaryData = try? container.decode([String: String].self, forKey: .summary) {
            summary = summaryData
        } else {
            summary = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(analysisDate, forKey: .analysisDate)
        
        if let summary = summary {
            try container.encode(summary, forKey: .summary)
        }
    }
}

struct SessionContext: Codable {
    let currentTopic: String?
    let userIntent: String?
    let conversationFlow: [String]?
    let contextualData: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case currentTopic = "current_topic"
        case userIntent = "user_intent"
        case conversationFlow = "conversation_flow"
        case contextualData = "contextual_data"
    }
    
    init(currentTopic: String? = nil, userIntent: String? = nil, conversationFlow: [String]? = nil, contextualData: [String: String]? = nil) {
        self.currentTopic = currentTopic
        self.userIntent = userIntent
        self.conversationFlow = conversationFlow
        self.contextualData = contextualData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentTopic = try container.decodeIfPresent(String.self, forKey: .currentTopic)
        userIntent = try container.decodeIfPresent(String.self, forKey: .userIntent)
        conversationFlow = try container.decodeIfPresent([String].self, forKey: .conversationFlow)
        
        // Handle Any type for contextualData
        if let contextData = try? container.decode([String: String].self, forKey: .contextualData) {
            contextualData = contextData
        } else {
            contextualData = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(currentTopic, forKey: .currentTopic)
        try container.encodeIfPresent(userIntent, forKey: .userIntent)
        try container.encodeIfPresent(conversationFlow, forKey: .conversationFlow)
        
        if let contextualData = contextualData {
            try container.encode(contextualData, forKey: .contextualData)
        }
    }
}

// MARK: - Main Model

struct ChatConversation: Codable, Identifiable {
    let id: UUID
    let userId: String
    let title: String
    let contextType: ContextType
    let sessionContext: SessionContext
    let sessionId: String
    let sessionType: SessionType
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case contextType = "context_type"
        case sessionContext = "session_context"
        case sessionId = "session_id"
        case sessionType = "session_type"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(
        id: UUID = UUID(),
        userId: String,
        title: String = "New Conversation",
        contextType: ContextType = .general,
        sessionContext: SessionContext = SessionContext(),
        sessionId: String = UUID().uuidString,
        sessionType: SessionType = .chat,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.contextType = contextType
        self.sessionContext = sessionContext
        self.sessionId = sessionId
        self.sessionType = sessionType
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Convenience Extensions

extension ChatConversation {
    var currentTopic: String? {
        sessionContext.currentTopic
    }
    
    func withUpdatedSessionContext(_ newContext: SessionContext) -> ChatConversation {
        ChatConversation(
            id: self.id,
            userId: self.userId,
            title: self.title,
            contextType: self.contextType,
            sessionContext: newContext,
            sessionId: self.sessionId,
            sessionType: self.sessionType,
            isActive: self.isActive,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
}

extension ChatConversation{
    func with(id: UUID? = nil, userId: String? = nil, title: String? = nil, contextType: ContextType? = nil, sessionContext: SessionContext? = nil, sessionId: String? = nil, sessionType: SessionType? = nil, isActive: Bool? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) -> ChatConversation {
        return ChatConversation(
            id: id ?? self.id,
            userId: userId ?? self.userId,
            title: title ?? self.title,
            contextType: contextType ?? self.contextType,
            sessionContext: sessionContext ?? self.sessionContext,
            sessionId: sessionId ?? self.sessionId,
            sessionType: sessionType ?? self.sessionType,
            isActive: isActive ?? self.isActive,
            createdAt: createdAt ?? self.createdAt,
            updatedAt: updatedAt ?? self.updatedAt
        )
    }
}
