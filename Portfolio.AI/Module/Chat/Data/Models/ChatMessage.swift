//
//  ChatMessage.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import Foundation

// MARK: - Enums

enum MessageRole: String, Codable, CaseIterable {
    case user
    case assistant
    case system
}

// MARK: - Support Models

struct MessageMetadata: Codable {
    let messageType: String?
    let sourceContext: String?
    let attachmentCount: Int?
    let processingModel: String?
    let temperature: Double?
    let maxTokens: Int?
    let additionalData: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case messageType = "message_type"
        case sourceContext = "source_context"
        case attachmentCount = "attachment_count"
        case processingModel = "processing_model"
        case temperature
        case maxTokens = "max_tokens"
        case additionalData = "additional_data"
    }
    
    init(
        messageType: String? = nil,
        sourceContext: String? = nil,
        attachmentCount: Int? = nil,
        processingModel: String? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil,
        additionalData: [String: String]? = nil
    ) {
        self.messageType = messageType
        self.sourceContext = sourceContext
        self.attachmentCount = attachmentCount
        self.processingModel = processingModel
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.additionalData = additionalData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageType = try container.decodeIfPresent(String.self, forKey: .messageType)
        sourceContext = try container.decodeIfPresent(String.self, forKey: .sourceContext)
        attachmentCount = try container.decodeIfPresent(Int.self, forKey: .attachmentCount)
        processingModel = try container.decodeIfPresent(String.self, forKey: .processingModel)
        temperature = try container.decodeIfPresent(Double.self, forKey: .temperature)
        maxTokens = try container.decodeIfPresent(Int.self, forKey: .maxTokens)
        
        // Handle Any type for additionalData
        if let additionalData = try? container.decode([String: String].self, forKey: .additionalData) {
            self.additionalData = additionalData
        } else {
            self.additionalData = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(messageType, forKey: .messageType)
        try container.encodeIfPresent(sourceContext, forKey: .sourceContext)
        try container.encodeIfPresent(attachmentCount, forKey: .attachmentCount)
        try container.encodeIfPresent(processingModel, forKey: .processingModel)
        try container.encodeIfPresent(temperature, forKey: .temperature)
        try container.encodeIfPresent(maxTokens, forKey: .maxTokens)
        
        if let additionalData = additionalData {
            try container.encode(additionalData, forKey: .additionalData)
        }
    }
}

// MARK: - Main Model

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let conversationId: UUID
    let userId: String
    let role: MessageRole
    let content: String
    let metadata: MessageMetadata?
    let tokensUsed: Int
    let processingTimeMs: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case userId = "user_id"
        case role
        case content
        case metadata
        case tokensUsed = "tokens_used"
        case processingTimeMs = "processing_time_ms"
        case createdAt = "created_at"
    }
    
    init(
        id: UUID = UUID(),
        conversationId: UUID,
        userId: String,
        role: MessageRole,
        content: String,
        metadata: MessageMetadata? = nil,
        tokensUsed: Int = 0,
        processingTimeMs: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.conversationId = conversationId
        self.userId = userId
        self.role = role
        self.content = content
        self.metadata = metadata
        self.tokensUsed = tokensUsed
        self.processingTimeMs = processingTimeMs
        self.createdAt = createdAt
    }
}

// MARK: - Convenience Extensions

extension ChatMessage {
    var isFromUser: Bool {
        role == .user
    }
    
    var isFromAssistant: Bool {
        role == .assistant
    }
    
    var isSystemMessage: Bool {
        role == .system
    }
    
    var hasAttachments: Bool {
        metadata?.attachmentCount ?? 0 > 0
    }
    
    var attachmentCount: Int {
        metadata?.attachmentCount ?? 0
    }
    
    var processingTimeSeconds: Double {
        Double(processingTimeMs) / 1000.0
    }
    
    var shortContent: String {
        if content.count <= 100 {
            return content
        }
        return String(content.prefix(97)) + "..."
    }
    
    static func userMessage(
        conversationId: UUID,
        userId: String,
        content: String,
        metadata: MessageMetadata? = nil
    ) -> ChatMessage {
        ChatMessage(
            conversationId: conversationId,
            userId: userId,
            role: .user,
            content: content,
            metadata: metadata
        )
    }
    
    static func assistantMessage(
        conversationId: UUID,
        userId: String,
        content: String,
        tokensUsed: Int = 0,
        processingTimeMs: Int = 0,
        metadata: MessageMetadata? = nil
    ) -> ChatMessage {
        ChatMessage(
            conversationId: conversationId,
            userId: userId,
            role: .assistant,
            content: content,
            metadata: metadata,
            tokensUsed: tokensUsed,
            processingTimeMs: processingTimeMs
        )
    }
    
    static func systemMessage(
        conversationId: UUID,
        userId: String,
        content: String,
        metadata: MessageMetadata? = nil
    ) -> ChatMessage {
        ChatMessage(
            conversationId: conversationId,
            userId: userId,
            role: .system,
            content: content,
            metadata: metadata
        )
    }
}

// MARK: - Hashable Conformance

extension ChatMessage: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}
