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
    @Published var currentConversation: ChatConversation? = nil
    @Published var messages: [ChatMessage] = []

    // MARK: - Loading States

    @Published var isLoadingConversations: Bool = false
    @Published var isLoadingMessages: Bool = false
    @Published var isSendingMessage: Bool = false
    @Published var isCreatingConversation: Bool = false

    // MARK: - Streaming State

    /// In-progress assistant reply, one entry per bubble. This is the *displayed*
    /// text — revealed gradually by the typewriter so it grows smoothly instead
    /// of jumping a whole network chunk at a time. Cleared once the final
    /// messages are persisted.
    @Published var streamingBubbles: [String] = []
    @Published var isStreaming: Bool = false

    /// Full text received from the model so far; the typewriter catches up to it.
    private var targetBubbles: [String] = []
    private var typewriterTask: Task<Void, Never>?

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
            let (paginatedResponse, error) = await ChatRepo.fetchConversations(
                pagination: conversationsPagination
            )

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
            initialSessionContext: initialSessionContext ?? SessionContext()
        )

        let (conversation, error) = await ChatRepo.createConversation(
            request: request
        )

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
            let (conversation, error) = await ChatRepo.fetchConversation(
                id: conversationId
            )

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
            let (updatedConversation, error) =
                await ChatRepo.updateConversation(
                    id: conversationId,
                    title: title
                )

            await MainActor.run {
                if let updated = updatedConversation {
                    if currentConversation?.id == conversationId {
                        currentConversation = updated
                    }
                    // Update in conversations list
                    if let index = conversations.firstIndex(where: {
                        $0.id == conversationId
                    }) {
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
            let (success, error) = await ChatRepo.deleteConversation(
                id: conversationId
            )

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
        }
        return message
    }

    /// Convenience method to send user message and get AI response
    func sendMessage(content: String, portfolioContext: String) async {
        isSendingMessage = true
        // Send user message
        let userMessage = await sendMessage(content: content, role: .user)

        guard userMessage != nil else { return }

       if let conversation = currentConversation,
           conversation.title == "New Conversation"
       {
           updateConversationTitle(conversation.id, title: content)
       }

        await generateAIResponse(
            for: content,
            portfolioContext: portfolioContext
        )

        isSendingMessage = false
    }

    /// Generate AI response using Gemini API (streamed).
    private func generateAIResponse(
        for userMessage: String,
        portfolioContext: String
    ) async {
        // Get recent messages for context (last 5 messages)
        let recentMessages = Array(messages.suffix(5))

        // Get portfolio context from current conversation
        let portfolioContext = portfolioContext

        isStreaming = true
        streamingBubbles = []
        targetBubbles = []

        await GeminiRepo.streamChatResponse(
            userMessage: userMessage,
            conversationHistory: recentMessages,
            portfolioContext: portfolioContext,
            onUpdate: { [weak self] bubbles in
                Task { @MainActor in
                    self?.enqueueStreamUpdate(bubbles)
                }
            }
        ) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }

                switch result {
                case .success(let chatResponse):
                    // Stop the typewriter and reveal any remaining tail so the
                    // final on-screen text matches what we persist.
                    self.stopTypewriter()
                    self.streamingBubbles = chatResponse.parts
                    // Persist each streamed bubble as its own assistant message,
                    // then swap the live bubbles for the persisted ones in a
                    // single step to avoid any flicker.
                    var persisted: [ChatMessage] = []
                    for part in chatResponse.parts
                    where !part.trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty {
                        if let saved = await self.persistAssistantMessage(
                            content: part,
                            tokensUsed: chatResponse.tokensUsed
                        ) {
                            persisted.append(saved)
                        }
                    }
                    self.messages.append(contentsOf: persisted)
                    self.streamingBubbles = []
                    self.isStreaming = false
                    self.updateConversationInList()

                case .failure(let error):
                    let errorResponse =
                        "I apologize, but I'm experiencing some technical difficulties at the moment. Please try again in a few moments. Error: \(error.localizedDescription)"

                    self.stopTypewriter()
                    self.streamingBubbles = []
                    self.isStreaming = false
                    _ = await self.sendMessage(
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

    /// Persist an assistant message to the backend without mutating local
    /// state, returning the saved message so callers can append it atomically.
    private func persistAssistantMessage(
        content: String,
        tokensUsed: Int
    ) async -> ChatMessage? {
        guard let conversationId = currentConversation?.id else { return nil }

        let (message, error) = await ChatRepo.sendMessage(
            conversationId: conversationId,
            content: content,
            role: .assistant,
            metadata: MessageMetadata(
                temperature: 0.7,
                maxTokens: tokensUsed
            )
        )

        if let error = error {
            handleError(error)
        }
        return message
    }

    // MARK: - Streaming Typewriter

    /// Record the latest full text from the model and make sure the typewriter
    /// is running to reveal it smoothly.
    private func enqueueStreamUpdate(_ bubbles: [String]) {
        targetBubbles = bubbles
        // Grow the displayed array so new bubbles exist (empty) before filling.
        if streamingBubbles.count < bubbles.count {
            streamingBubbles.append(
                contentsOf: Array(
                    repeating: "",
                    count: bubbles.count - streamingBubbles.count
                )
            )
        }
        startTypewriterIfNeeded()
    }

    private func startTypewriterIfNeeded() {
        guard typewriterTask == nil else { return }

        typewriterTask = Task { @MainActor in
            while !Task.isCancelled {
                var displayed = streamingBubbles
                var changed = false

                for i in targetBubbles.indices {
                    if i >= displayed.count { displayed.append("") }
                    let target = targetBubbles[i]
                    let shownCount = displayed[i].count
                    guard shownCount < target.count else { continue }

                    // Reveal a slice each tick; step scales with how far behind
                    // we are so the text never lags far yet still eases in.
                    let remaining = target.count - shownCount
                    let step = max(2, remaining / 6)
                    let end = target.index(
                        target.startIndex,
                        offsetBy: min(target.count, shownCount + step)
                    )
                    displayed[i] = String(target[..<end])
                    changed = true
                }

                if changed {
                    withAnimation(.easeOut(duration: 0.18)) {
                        streamingBubbles = displayed
                    }
                }

                // ~60fps reveal cadence.
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }

    private func stopTypewriter() {
        typewriterTask?.cancel()
        typewriterTask = nil
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
                    if let index = messages.firstIndex(where: {
                        $0.id == messageId
                    }) {
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
                } else if let error = error {
                    handleError(error)
                }
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
    private func updateSessionContextFromMessage(
        _ content: String,
        role: MessageRole
    ) {
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

    // MARK: - Utility Methods

    private func conversationToSummary(_ conversation: ChatConversation)
        -> ConversationSummary
    {
        return ConversationSummary(
            id: conversation.id,
            userId: conversation.userId,
            title: conversation.title,
            contextType: conversation.contextType,
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

        if let index = conversations.firstIndex(where: {
            $0.id == currentConversation.id
        }) {
            var updated = conversations[index]
            updated = ConversationSummary(
                id: updated.id,
                userId: updated.userId,
                title: updated.title,
                contextType: updated.contextType,
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

    func deleteChat() async -> Failure? {
        conversations.removeAll()
        currentConversation = nil
        messages.removeAll()
        return await ChatRepo.deleteAllChat()
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

    /// Clear current conversation
    func clearCurrentConversation() {
        currentConversation = nil
        messages.removeAll()
        currentSessionContext = SessionContext()
    }

    /// Refresh current conversation data
    func refreshCurrentConversation() {
        guard let conversationId = currentConversation?.id else { return }
        selectConversation(conversationId)
    }
}
