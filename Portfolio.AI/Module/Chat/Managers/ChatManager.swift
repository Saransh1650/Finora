//
//  ChatManager.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import Foundation
import SwiftUI

// Note: Import GeminiRepo from Home module - assuming it's accessible
// You may need to adjust this import based on your project structure

@MainActor
class ChatManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var conversations: [ConversationSummary] = []
    @Published var currentConversation: ChatConversation?
    @Published var messages: [ChatMessage] = []
    @Published var attachments: [UUID: [ChatAttachment]] = [:]
    
    // MARK: - Loading States
    
    @Published var isLoadingConversations: Bool = false
    @Published var isLoadingMessages: Bool = false
    @Published var isSendingMessage: Bool = false
    @Published var isCreatingConversation: Bool = false
    @Published var isUploadingAttachment: Bool = false
    
    // MARK: - Error Handling
    
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Pagination
    
    private var conversationsPagination = PaginationRequest(page: 1, limit: 20)
    private var messagesPagination = PaginationRequest(page: 1, limit: 50)
    private var hasMoreConversations = true
    private var hasMoreMessages = true
    
    // MARK: - Session Management
    
    @Published var currentSessionContext: SessionContext = SessionContext()
    
    init() {
        loadConversations()
    }
    
    // MARK: - Conversation Management
    
    /// Load conversations for the current user
    func loadConversations(refresh: Bool = false) {
        if refresh {
            conversations.removeAll()
            conversationsPagination = PaginationRequest(page: 1, limit: 20)
            hasMoreConversations = true
        }
        
        guard hasMoreConversations else { return }
        
        isLoadingConversations = true
        errorMessage = nil
        
        Task {
            let (paginatedResponse, error) = await ChatRepo.fetchConversations(pagination: conversationsPagination)
            
            await MainActor.run {
                if let response = paginatedResponse {
                    if refresh {
                        conversations = response.data
                    } else {
                        conversations.append(contentsOf: response.data)
                    }
                    hasMoreConversations = response.pagination.hasNextPage
                    conversationsPagination = PaginationRequest(
                        page: response.pagination.currentPage + 1,
                        limit: conversationsPagination.limit
                    )
                } else if let error = error {
                    handleError(error)
                }
                isLoadingConversations = false
            }
        }
    }
    
    /// Load more conversations (pagination)
    func loadMoreConversations() {
        if !isLoadingConversations && hasMoreConversations {
            loadConversations()
        }
    }
    
    /// Create a new conversation
    func createConversation(
        title: String? = nil,
        contextType: ContextType = .general,
        sessionType: SessionType = .chat,
        includePortfolioContext: Bool = true,
        initialSessionContext: SessionContext? = nil
    ) async -> ChatConversation? {
        isCreatingConversation = true
        errorMessage = nil
        
        let request = CreateConversationRequest(
            title: title,
            contextType: contextType,
            sessionType: sessionType,
            includePortfolioContext: includePortfolioContext,
            initialSessionContext: initialSessionContext ?? SessionContext()
        )
        
        let (conversation, error) = await ChatRepo.createConversation(request: request)
        
        await MainActor.run {
            if let conversation = conversation {
                currentConversation = conversation
                currentSessionContext = conversation.sessionContext
                // Add to conversations list at the beginning
                let summary = conversationToSummary(conversation)
                conversations.insert(summary, at: 0)
            } else if let error = error {
                handleError(error)
            }
            isCreatingConversation = false
        }
        
        return conversation
    }
    
    /// Select a conversation and load its messages
    func selectConversation(_ conversationId: UUID) {
        guard currentConversation?.id != conversationId else { return }
        
        Task {
            let (conversation, error) = await ChatRepo.fetchConversation(id: conversationId)
            
            await MainActor.run {
                if let conversation = conversation {
                    currentConversation = conversation
                    currentSessionContext = conversation.sessionContext
                    messages.removeAll()
                    messagesPagination = PaginationRequest(page: 1, limit: 50)
                    hasMoreMessages = true
                    loadMessages()
                } else if let error = error {
                    handleError(error)
                }
            }
        }
    }
    
    /// Update conversation title
    func updateConversationTitle(_ conversationId: UUID, title: String) {
        Task {
            let (updatedConversation, error) = await ChatRepo.updateConversation(id: conversationId, title: title)
            
            await MainActor.run {
                if let updated = updatedConversation {
                    if currentConversation?.id == conversationId {
                        currentConversation = updated
                    }
                    // Update in conversations list
                    if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
                        conversations[index] = conversationToSummary(updated)
                    }
                } else if let error = error {
                    handleError(error)
                }
            }
        }
    }
    
    /// Delete a conversation
    func deleteConversation(_ conversationId: UUID) {
        Task {
            let (success, error) = await ChatRepo.deleteConversation(id: conversationId)
            
            await MainActor.run {
                if success {
                    conversations.removeAll { $0.id == conversationId }
                    if currentConversation?.id == conversationId {
                        currentConversation = nil
                        messages.removeAll()
                    }
                } else if let error = error {
                    handleError(error)
                }
            }
        }
    }
    
    // MARK: - Message Management
    
    /// Load messages for the current conversation
    func loadMessages(refresh: Bool = false) {
        guard let conversationId = currentConversation?.id else { return }
        
        if refresh {
            messages.removeAll()
            messagesPagination = PaginationRequest(page: 1, limit: 50)
            hasMoreMessages = true
        }
        
        guard hasMoreMessages else { return }
        
        isLoadingMessages = true
        
        Task {
            let (paginatedResponse, error) = await ChatRepo.fetchMessages(
                conversationId: conversationId,
                pagination: messagesPagination
            )
            
            await MainActor.run {
                if let response = paginatedResponse {
                    if refresh {
                        messages = response.data
                    } else {
                        messages.append(contentsOf: response.data)
                    }
                    hasMoreMessages = response.pagination.hasNextPage
                    messagesPagination = PaginationRequest(
                        page: response.pagination.currentPage + 1,
                        limit: messagesPagination.limit
                    )
                    
                    // Load attachments for messages
                    loadAttachmentsForMessages(response.data)
                } else if let error = error {
                    handleError(error)
                }
                isLoadingMessages = false
            }
        }
    }
    
    /// Load more messages (pagination)
    func loadMoreMessages() {
        if !isLoadingMessages && hasMoreMessages {
            loadMessages()
        }
    }
    
    /// Send a message
    func sendMessage(
        content: String,
        role: MessageRole = .user,
        metadata: MessageMetadata? = nil
    ) async -> ChatMessage? {
        guard let conversationId = currentConversation?.id else { return nil }
        
        isSendingMessage = true
        
        let (message, error) = await ChatRepo.sendMessage(
            conversationId: conversationId,
            content: content,
            role: role,
            metadata: metadata
        )
        
        await MainActor.run {
            if let message = message {
                messages.append(message)
                updateConversationInList()
                updateSessionContextFromMessage(content, role: role)
            } else if let error = error {
                handleError(error)
            }
            isSendingMessage = false
        }
        print("Sent message: \(String(describing: message?.metadata))")
        return message
    }
    
    /// Convenience method to send user message and get AI response
    func sendMessage(content: String) async {
        // Send user message
        let userMessage = await sendMessage(content: content, role: .user)
        
        guard userMessage != nil else { return }
        
        // TODO: Implement AI response generation
        // For now, simulate an AI response after a short delay
        await generateAIResponse(for: content)
    }
    
    /// Generate AI response using Gemini API
    private func generateAIResponse(for userMessage: String) async {
        // Get recent messages for context (last 5 messages)
        let recentMessages = Array(messages.suffix(5))
        
        await GeminiRepo.getChatResponse(
            userMessage: userMessage,
            conversationHistory: recentMessages
        ) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                
                switch result {
                case .success(let chatResponse):
                    await self.sendMessage(
                        content: chatResponse.content,
                        role: .assistant,
                        metadata: MessageMetadata(
                            temperature: 0.7,
                            maxTokens: chatResponse.tokensUsed
                        )
                    )
                    
                case .failure(let error):
                    // Fallback to a generic error response
                    let errorResponse = "I apologize, but I'm experiencing some technical difficulties at the moment. Please try again in a few moments. Error: \(error.localizedDescription)"
                    
                    await self.sendMessage(
                        content: errorResponse,
                        role: .assistant,
                        metadata: MessageMetadata(
                            temperature: 0.7,
                            maxTokens: 100
                        )
                    )
                }
            }
        }
    }
    
    // MARK: - Message Management
    func updateMessage(
        _ messageId: UUID,
        content: String? = nil,
        metadata: MessageMetadata? = nil,
        tokensUsed: Int? = nil,
        processingTimeMs: Int? = nil
    ) {
        Task {
            let (updatedMessage, error) = await ChatRepo.updateMessage(
                id: messageId,
                content: content,
                metadata: metadata,
                tokensUsed: tokensUsed,
                processingTimeMs: processingTimeMs
            )
            
            await MainActor.run {
                if let updated = updatedMessage {
                    if let index = messages.firstIndex(where: { $0.id == messageId }) {
                        messages[index] = updated
                    }
                } else if let error = error {
                    handleError(error)
                }
            }
        }
    }
    
    /// Delete a message
    func deleteMessage(_ messageId: UUID) {
        Task {
            let (success, error) = await ChatRepo.deleteMessage(id: messageId)
            
            await MainActor.run {
                if success {
                    messages.removeAll { $0.id == messageId }
                    attachments.removeValue(forKey: messageId)
                } else if let error = error {
                    handleError(error)
                }
            }
        }
    }
    
    // MARK: - Attachment Management
    
    /// Load attachments for messages
    private func loadAttachmentsForMessages(_ messages: [ChatMessage]) {
        for message in messages {
            if message.hasAttachments {
                loadAttachments(for: message.id)
            }
        }
    }
    
    /// Load attachments for a specific message
    func loadAttachments(for messageId: UUID) {
        Task {
            let (messageAttachments, error) = await ChatAttachmentRepo.fetchAttachments(messageId: messageId)
            
            await MainActor.run {
                if let messageAttachments = messageAttachments {
                    attachments[messageId] = messageAttachments
                } else if let error = error {
                    handleError(error)
                }
            }
        }
    }
    
    /// Upload an attachment
    func uploadAttachment(
        messageId: UUID,
        fileName: String,
        fileType: String,
        fileData: Data,
        metadata: AttachmentMetadata? = nil
    ) {
        isUploadingAttachment = true
        
        Task {
            let (attachment, error) = await ChatAttachmentRepo.uploadAttachment(
                messageId: messageId,
                fileName: fileName,
                fileType: fileType,
                fileSize: fileData.count,
                fileData: fileData,
                metadata: metadata
            )
            
            await MainActor.run {
                if let attachment = attachment {
                    if attachments[messageId] == nil {
                        attachments[messageId] = []
                    }
                    attachments[messageId]?.append(attachment)
                } else if let error = error {
                    handleError(error)
                }
                isUploadingAttachment = false
            }
        }
    }
    
    // MARK: - Session Management
    
    /// Update session context
    func updateSessionContext(_ newContext: SessionContext) {
        guard let conversationId = currentConversation?.id else { return }
        
        currentSessionContext = newContext
        
        Task {
            let (success, error) = await ChatRepo.updateSessionContext(
                conversationId: conversationId,
                sessionContext: newContext
            )
            
            await MainActor.run {
                if !success, let error = error {
                    handleError(error)
                }
            }
        }
    }
    
    /// Update session context based on message content
    private func updateSessionContextFromMessage(_ content: String, role: MessageRole) {
        var updatedContext = currentSessionContext
        
        // Update conversation flow
        if var flow = updatedContext.conversationFlow {
            flow.append("\(role.rawValue)_message")
            updatedContext = SessionContext(
                currentTopic: updatedContext.currentTopic,
                userIntent: updatedContext.userIntent,
                conversationFlow: flow,
                contextualData: updatedContext.contextualData
            )
        } else {
            updatedContext = SessionContext(
                currentTopic: updatedContext.currentTopic,
                userIntent: updatedContext.userIntent,
                conversationFlow: ["\(role.rawValue)_message"],
                contextualData: updatedContext.contextualData
            )
        }
        
        updateSessionContext(updatedContext)
    }
    
    // MARK: - Search and Analytics
    
    /// Search messages
    func searchMessages(
        query: String,
        conversationId: UUID? = nil
    ) async -> [ChatMessage] {
        let (paginatedResponse, error) = await ChatSearchAndAnalyticsRepo.searchMessages(
            query: query,
            conversationId: conversationId,
            pagination: PaginationRequest(page: 1, limit: 100)
        )
        
        if let response = paginatedResponse {
            return response.data
        } else if let error = error {
            await MainActor.run {
                handleError(error)
            }
        }
        
        return []
    }
    
    /// Get conversation statistics
    func getConversationStats(_ conversationId: UUID) async -> [String: String]? {
        let (stats, error) = await ChatSearchAndAnalyticsRepo.getConversationStats(conversationId: conversationId)
        
        if let error = error {
            await MainActor.run {
                handleError(error)
            }
        }
        
        return stats
    }
    
    // MARK: - Utility Methods
    
    private func conversationToSummary(_ conversation: ChatConversation) -> ConversationSummary {
        return ConversationSummary(
            id: conversation.id,
            userId: conversation.userId,
            title: conversation.title,
            contextType: conversation.contextType,
            portfolioContext: conversation.portfolioContext,
            sessionContext: conversation.sessionContext,
            sessionId: conversation.sessionId,
            sessionType: conversation.sessionType,
            isActive: conversation.isActive,
            createdAt: conversation.createdAt,
            updatedAt: conversation.updatedAt,
            messageCount: 0,
            lastMessageAt: nil,
            lastMessagePreview: ""
        )
    }
    
    private func updateConversationInList() {
        guard let currentConversation = currentConversation else { return }
        
        if let index = conversations.firstIndex(where: { $0.id == currentConversation.id }) {
            var updated = conversations[index]
            updated = ConversationSummary(
                id: updated.id,
                userId: updated.userId,
                title: updated.title,
                contextType: updated.contextType,
                portfolioContext: updated.portfolioContext,
                sessionContext: currentSessionContext,
                sessionId: updated.sessionId,
                sessionType: updated.sessionType,
                isActive: updated.isActive,
                createdAt: updated.createdAt,
                updatedAt: Date(),
                messageCount: messages.count,
                lastMessageAt: messages.last?.createdAt,
                lastMessagePreview: messages.last?.shortContent ?? ""
            )
            conversations[index] = updated
        }
    }
    
    private func handleError(_ error: Failure) {
        errorMessage = error.message
        showError = true
        print("ChatManager Error: \(String(describing: error.message))")
    }
    
    // MARK: - Public Helper Methods
    
    /// Check if there are more conversations to load
    var canLoadMoreConversations: Bool {
        hasMoreConversations && !isLoadingConversations
    }
    
    /// Check if there are more messages to load
    var canLoadMoreMessages: Bool {
        hasMoreMessages && !isLoadingMessages
    }
    
    /// Get attachments for a specific message
    func getAttachments(for messageId: UUID) -> [ChatAttachment] {
        return attachments[messageId] ?? []
    }
    
    /// Clear current conversation
    func clearCurrentConversation() {
        currentConversation = nil
        messages.removeAll()
        attachments.removeAll()
        currentSessionContext = SessionContext()
    }
    
    /// Refresh current conversation data
    func refreshCurrentConversation() {
        guard let conversationId = currentConversation?.id else { return }
        selectConversation(conversationId)
    }
}
