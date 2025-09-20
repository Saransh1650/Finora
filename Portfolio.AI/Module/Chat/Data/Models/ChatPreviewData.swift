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
    let portfolioContext: PortfolioContext
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
        case portfolioContext = "portfolio_context"
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
    
    init(
        id: UUID,
        userId: String,
        title: String,
        contextType: ContextType,
        portfolioContext: PortfolioContext,
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
        self.portfolioContext = portfolioContext
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
    let includePortfolioContext: Bool?
    let initialSessionContext: SessionContext?
    
    enum CodingKeys: String, CodingKey {
        case title
        case contextType = "context_type"
        case sessionType = "session_type"
        case includePortfolioContext = "include_portfolio_context"
        case initialSessionContext = "initial_session_context"
    }
    
    init(
        title: String? = nil,
        contextType: ContextType? = nil,
        sessionType: SessionType? = nil,
        includePortfolioContext: Bool? = nil,
        initialSessionContext: SessionContext? = nil
    ) {
        self.title = title
        self.contextType = contextType
        self.sessionType = sessionType
        self.includePortfolioContext = includePortfolioContext
        self.initialSessionContext = initialSessionContext
    }
}

struct SendMessageRequest: Codable {
    let content: String
    let metadata: MessageMetadata?
    let attachments: [AttachmentUploadInfo]?
    
    enum CodingKeys: String, CodingKey {
        case content
        case metadata
        case attachments
    }
    
    init(
        content: String,
        metadata: MessageMetadata? = nil,
        attachments: [AttachmentUploadInfo]? = nil
    ) {
        self.content = content
        self.metadata = metadata
        self.attachments = attachments
    }
}

struct AttachmentUploadInfo: Codable {
    let fileName: String
    let fileType: String
    let fileSize: Int
    let fileData: Data?
    let metadata: AttachmentMetadata?
    
    enum CodingKeys: String, CodingKey {
        case fileName = "file_name"
        case fileType = "file_type"
        case fileSize = "file_size"
        case fileData = "file_data"
        case metadata
    }
    
    init(
        fileName: String,
        fileType: String,
        fileSize: Int,
        fileData: Data? = nil,
        metadata: AttachmentMetadata? = nil
    ) {
        self.fileName = fileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.fileData = fileData
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
    let attachments: [ChatAttachment]?
    
    init(
        conversation: ChatConversation? = nil,
        message: ChatMessage? = nil,
        messages: [ChatMessage]? = nil,
        conversations: [ConversationSummary]? = nil,
        attachments: [ChatAttachment]? = nil
    ) {
        self.conversation = conversation
        self.message = message
        self.messages = messages
        self.conversations = conversations
        self.attachments = attachments
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
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case totalItems = "total_items"
        case itemsPerPage = "items_per_page"
        case hasNextPage = "has_next_page"
        case hasPreviousPage = "has_previous_page"
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

// MARK: - Conversation Extensions

extension ConversationSummary {
    var isPortfolioEnabled: Bool {
        portfolioContext.enabled
    }
    
    var hasRecentActivity: Bool {
        guard let lastMessageAt = lastMessageAt else { return false }
        let daysSinceLastMessage = Calendar.current.dateComponents([.day], from: lastMessageAt, to: Date()).day ?? 0
        return daysSinceLastMessage <= 7
    }
    
    var activityStatus: String {
        if messageCount == 0 {
            return "New conversation"
        } else if hasRecentActivity {
            return "Active"
        } else {
            return "Inactive"
        }
    }
    
    var formattedLastMessageTime: String {
        guard let lastMessageAt = lastMessageAt else { return "Never" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastMessageAt, relativeTo: Date())
    }
}

// MARK: - Preview Data for SwiftUI

extension ConversationSummary {
    static let preview = ConversationSummary(
        id: UUID(),
        userId: "user123",
        title: "Portfolio Analysis Discussion",
        contextType: .portfolio,
        portfolioContext: PortfolioContext(
            enabled: true,
            portfolioSummary: PortfolioSummary(
                totalStocks: 5,
                totalInvested: 10000.0,
                topStocks: ["AAPL", "GOOGL", "MSFT"],
                lastUpdated: Date()
            )
        ),
        sessionContext: SessionContext(
            currentTopic: "Portfolio performance review",
            userIntent: "analysis",
            conversationFlow: ["greeting", "portfolio_review", "recommendations"]
        ),
        sessionId: UUID().uuidString,
        sessionType: .analysis,
        isActive: true,
        createdAt: Date().addingTimeInterval(-86400), // 1 day ago
        updatedAt: Date().addingTimeInterval(-3600), // 1 hour ago
        messageCount: 12,
        lastMessageAt: Date().addingTimeInterval(-3600),
        lastMessagePreview: "Based on your portfolio analysis, I recommend..."
    )
    
    static let previewList = [
        preview,
        ConversationSummary(
            id: UUID(),
            userId: "user123",
            title: "Market Insights Chat",
            contextType: .marketInsights,
            portfolioContext: PortfolioContext(enabled: false),
            sessionContext: SessionContext(),
            sessionId: UUID().uuidString,
            sessionType: .chat,
            isActive: true,
            createdAt: Date().addingTimeInterval(-172800), // 2 days ago
            updatedAt: Date().addingTimeInterval(-7200), // 2 hours ago
            messageCount: 8,
            lastMessageAt: Date().addingTimeInterval(-7200),
            lastMessagePreview: "The current market trends show..."
        )
    ]
}
