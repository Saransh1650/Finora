//
//  ChatPreviewData.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import Foundation

// MARK: - Conversation Summary Model

struct ConversationSummary: Codable, Identifiable {
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
    let messageCount: Int
    let lastMessageAt: Date?
    let lastMessagePreview: String
    
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
        case messageCount = "message_count"
        case lastMessageAt = "last_message_at"
        case lastMessagePreview = "last_message_preview"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        
        // Handle context_type string to enum conversion
        let contextTypeString = try container.decode(String.self, forKey: .contextType)
        contextType = ContextType(rawValue: contextTypeString) ?? .general
        
        // Handle session_context - backend now ensures it's always an object
        sessionContext = try container.decode(SessionContext.self, forKey: .sessionContext)
        
        sessionId = try container.decode(String.self, forKey: .sessionId)
        
        // Handle session_type string to enum conversion
        let sessionTypeString = try container.decode(String.self, forKey: .sessionType)
        sessionType = SessionType(rawValue: sessionTypeString) ?? .chat
        
        // Handle is_active - backend now sends proper boolean
        isActive = try container.decode(Bool.self, forKey: .isActive)
        
        // Handle date parsing - backend now sends consistent ISO strings
        let dateFormatter = ISO8601DateFormatter()
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        
        messageCount = try container.decode(Int.self, forKey: .messageCount)
        
        // Handle optional last_message_at
        if let lastMessageAtString = try? container.decode(String.self, forKey: .lastMessageAt) {
            lastMessageAt = dateFormatter.date(from: lastMessageAtString)
        } else {
            lastMessageAt = nil
        }
        
        lastMessagePreview = try container.decode(String.self, forKey: .lastMessagePreview)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(title, forKey: .title)
        try container.encode(contextType.rawValue, forKey: .contextType)
        try container.encode(sessionContext, forKey: .sessionContext)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(sessionType.rawValue, forKey: .sessionType)
        try container.encode(isActive, forKey: .isActive)
        
        let dateFormatter = ISO8601DateFormatter()
        try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(dateFormatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(messageCount, forKey: .messageCount)
        
        if let lastMessageAt = lastMessageAt {
            try container.encode(dateFormatter.string(from: lastMessageAt), forKey: .lastMessageAt)
        }
        
        try container.encode(lastMessagePreview, forKey: .lastMessagePreview)
    }
    
    init(
        id: UUID,
        userId: String,
        title: String,
        contextType: ContextType,
        sessionContext: SessionContext,
        sessionId: String,
        sessionType: SessionType,
        isActive: Bool,
        createdAt: Date,
        updatedAt: Date,
        messageCount: Int,
        lastMessageAt: Date? = nil,
        lastMessagePreview: String = ""
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
        self.messageCount = messageCount
        self.lastMessageAt = lastMessageAt
        self.lastMessagePreview = lastMessagePreview
    }
}

// MARK: - Chat Response Models

struct CreateConversationRequest: Codable {
    let title: String?
    let contextType: ContextType?
    let sessionType: SessionType?
    let initialSessionContext: SessionContext?
    
    enum CodingKeys: String, CodingKey {
        case title
        case contextType = "context_type"
        case sessionType = "session_type"
        case initialSessionContext = "initial_session_context"
    }
    
    init(
        title: String? = nil,
        contextType: ContextType? = nil,
        sessionType: SessionType? = nil,
        initialSessionContext: SessionContext? = nil
    ) {
        self.title = title
        self.contextType = contextType
        self.sessionType = sessionType
        self.initialSessionContext = initialSessionContext
    }
}

struct SendMessageRequest: Codable {
    let content: String
    let metadata: MessageMetadata?
    
    enum CodingKeys: String, CodingKey {
        case content
        case metadata
    }
    
    init(
        content: String,
        metadata: MessageMetadata? = nil,
    ) {
        self.content = content
        self.metadata = metadata
    }
}


struct ChatResponse: Codable {
    let success: Bool
    let message: String?
    let data: ChatResponseData?
    let error: ChatError?
    
    init(
        success: Bool,
        message: String? = nil,
        data: ChatResponseData? = nil,
        error: ChatError? = nil
    ) {
        self.success = success
        self.message = message
        self.data = data
        self.error = error
    }
}

struct ChatResponseData: Codable {
    let conversation: ChatConversation?
    let message: ChatMessage?
    let messages: [ChatMessage]?
    let conversations: [ConversationSummary]?
    
    init(
        conversation: ChatConversation? = nil,
        message: ChatMessage? = nil,
        messages: [ChatMessage]? = nil,
        conversations: [ConversationSummary]? = nil,
    ) {
        self.conversation = conversation
        self.message = message
        self.messages = messages
        self.conversations = conversations
    }
}

struct ChatError: Codable, Error {
    let code: String
    let message: String
    let details: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case details
    }
    
    init(
        code: String,
        message: String,
        details: [String: String]? = nil
    ) {
        self.code = code
        self.message = message
        self.details = details
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)
        
        // Handle Any type for details
        if let details = try? container.decode([String: String].self, forKey: .details) {
            self.details = details
        } else {
            self.details = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(message, forKey: .message)
        
        if let details = details {
            try container.encode(details, forKey: .details)
        }
    }
}

// MARK: - Pagination Models

struct PaginationRequest: Codable {
    let page: Int
    let limit: Int
    let sortBy: String?
    let sortOrder: SortOrder?
    
    enum CodingKeys: String, CodingKey {
        case page
        case limit
        case sortBy = "sort_by"
        case sortOrder = "sort_order"
    }
    
    init(
        page: Int = 1,
        limit: Int = 20,
        sortBy: String? = nil,
        sortOrder: SortOrder? = nil
    ) {
        self.page = page
        self.limit = limit
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
}

enum SortOrder: String, Codable, CaseIterable {
    case ascending = "asc"
    case descending = "desc"
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let pagination: PaginationInfo
    
    init(data: [T], pagination: PaginationInfo) {
        self.data = data
        self.pagination = pagination
    }
}

struct PaginationInfo: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "page"        // Backend sends "page"
        case totalPages = "totalPages"   // Backend sends "totalPages"
        case totalItems = "total"        // Backend sends "total"
        case itemsPerPage = "limit"      // Backend sends "limit"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        currentPage = try container.decode(Int.self, forKey: .currentPage)
        totalPages = try container.decode(Int.self, forKey: .totalPages)
        totalItems = try container.decode(Int.self, forKey: .totalItems)
        itemsPerPage = try container.decode(Int.self, forKey: .itemsPerPage)
        
        // Calculate computed properties
        hasNextPage = currentPage < totalPages
        hasPreviousPage = currentPage > 1
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentPage, forKey: .currentPage)
        try container.encode(totalPages, forKey: .totalPages)
        try container.encode(totalItems, forKey: .totalItems)
        try container.encode(itemsPerPage, forKey: .itemsPerPage)
    }
    
    init(
        currentPage: Int,
        totalPages: Int,
        totalItems: Int,
        itemsPerPage: Int
    ) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalItems = totalItems
        self.itemsPerPage = itemsPerPage
        self.hasNextPage = currentPage < totalPages
        self.hasPreviousPage = currentPage > 1
    }
}

