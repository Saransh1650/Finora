//
//  ChatRepo.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import Foundation
import Supabase

class ChatRepo {
    static private let supabase = SupabaseManager.shared.client

    static private var currentUserId: String? {
        supabase.auth.currentUser?.id.uuidString
    }

    /// Fetch all conversations for the current user (optimized with retry logic)
    static func fetchConversations(
        pagination: PaginationRequest = PaginationRequest()
    ) async -> (PaginatedResponse<ConversationSummary>?, Failure?) {
        guard let userId = currentUserId else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: .fetchError
                )
            )
        }

        print(
            "🟢 ChatRepo Debug: Starting fetchConversations for userId: \(userId)"
        )

        let maxRetries = 2
        var retryCount = 0

        while retryCount < maxRetries {
            do {
                let offset = (pagination.page - 1) * pagination.limit
                let countResponse: Int =
                    try await supabase
                    .from("chat_conversations")
                    .select("*", head: true, count: .exact)
                    .eq("user_id", value: userId)
                    .eq("is_active", value: true)
                    .execute()
                    .count ?? 0

                print(
                    "🟢 ChatRepo Debug: Total active conversations count: \(countResponse)"
                )
                let rawResponse: [[String: AnyJSON]] =
                    try await supabase
                    .from("chat_conversations")
                    .select("*")
                    .eq("user_id", value: userId)
                    .eq("is_active", value: true)
                    .order("updated_at", ascending: false)
                    .range(from: offset, to: offset + pagination.limit - 1)
                    .execute()
                    .value

                print(
                    "🟢 ChatRepo Debug: Raw response count: \(rawResponse.count)"
                )
                let conversations: [ConversationSummary] =
                    rawResponse.compactMap { row in
                        guard let idString = row["id"]?.stringValue,
                            let id = UUID(uuidString: idString),
                            let userIdString = row["user_id"]?.stringValue
                        else {
                            print(
                                "🔴 ChatRepo Debug: Failed to parse basic fields from row"
                            )
                            return nil
                        }

                        let title =
                            row["title"]?.stringValue ?? "New Conversation"
                        let contextTypeString =
                            row["context_type"]?.stringValue ?? "general"
                        let contextType =
                            ContextType(rawValue: contextTypeString) ?? .general
                        let sessionId =
                            row["session_id"]?.stringValue ?? UUID().uuidString
                        let sessionTypeString =
                            row["session_type"]?.stringValue ?? "chat"
                        let sessionType =
                            SessionType(rawValue: sessionTypeString) ?? .chat
                        let isActive = row["is_active"]?.boolValue ?? true

                        let createdAt =
                            DateParser.parseDate(from: row["created_at"])
                            ?? Date()
                        let updatedAt =
                            DateParser.parseDate(from: row["updated_at"])
                            ?? Date()

                        return ConversationSummary(
                            id: id,
                            userId: userIdString,
                            title: title,
                            contextType: contextType,
                            sessionContext: SessionContext(),
                            sessionId: sessionId,
                            sessionType: sessionType,
                            isActive: isActive,
                            createdAt: createdAt,
                            updatedAt: updatedAt,
                            messageCount: 0,
                            lastMessageAt: nil,
                            lastMessagePreview: ""
                        )
                    }

                print(
                    "🟢 ChatRepo Debug: Successfully converted \(conversations.count) conversations"
                )

                let totalPages = Int(
                    ceil(Double(countResponse) / Double(pagination.limit))
                )
                let paginationInfo = PaginationInfo(
                    currentPage: pagination.page,
                    totalPages: totalPages,
                    totalItems: countResponse,
                    itemsPerPage: pagination.limit
                )

                let paginatedResponse = PaginatedResponse(
                    data: conversations,
                    pagination: paginationInfo
                )
                return (paginatedResponse, nil)

            } catch {
                print(
                    "🔴 ChatRepo Debug: Attempt \(retryCount + 1) failed with error: \(error)"
                )
                if shouldRetryError(error) {
                    print(
                        "🟡 ChatRepo Debug: Detected retryable error in fetchConversations, retrying..."
                    )

                    retryCount += 1
                    if retryCount < maxRetries {
                        // Brief delay before retry
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        continue
                    }
                }
                if let decodingError = error as? DecodingError {
                    print(
                        "🔴 ChatRepo Debug: Decoding error details: \(decodingError)"
                    )
                }
                return (
                    nil,
                    Failure(
                        message:
                            "Error fetching conversations: \(error.localizedDescription)",
                        errorType: .fetchError
                    )
                )
            }
        }

        return (
            nil,
            Failure(
                message:
                    "Failed to fetch conversations after \(maxRetries) attempts",
                errorType: .fetchError
            )
        )
    }

    /// Fetch a specific conversation by ID with retry logic
    static func fetchConversation(id: UUID) async -> (
        ChatConversation?, Failure?
    ) {
        guard let userId = currentUserId else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: .fetchError
                )
            )
        }

        print("🟢 ChatRepo Debug: Fetching conversation with ID: \(id)")

        let maxRetries = 3
        var retryCount = 0

        while retryCount < maxRetries {
            do {
                let rawResponse: [[String: AnyJSON]] =
                    try await supabase
                    .from("chat_conversations")
                    .select("*")
                    .eq("id", value: id.uuidString)
                    .eq("user_id", value: userId)
                    .limit(1)
                    .execute()
                    .value

                print(
                    "🟢 ChatRepo Debug: Raw conversation response count: \(rawResponse.count)"
                )

                guard let conversationData = rawResponse.first else {
                    print(
                        "🔴 ChatRepo Debug: No conversation found with ID: \(id)"
                    )
                    return (
                        nil,
                        Failure(
                            message: "Conversation not found",
                            errorType: .fetchError
                        )
                    )
                }

                print(
                    "🟢 ChatRepo Debug: Found conversation data keys: \(conversationData.keys)"
                )

                // Manually construct ChatConversation with better error handling
                guard let idString = conversationData["id"]?.stringValue,
                    let conversationId = UUID(uuidString: idString)
                else {
                    print(
                        "🔴 ChatRepo Debug: Failed to parse ID from: \(conversationData["id"] ?? "nil")"
                    )
                    return (
                        nil,
                        Failure(
                            message: "Invalid conversation ID",
                            errorType: .fetchError
                        )
                    )
                }

                guard
                    let userIdString = conversationData["user_id"]?.stringValue
                else {
                    print("🔴 ChatRepo Debug: Failed to parse user_id")
                    return (
                        nil,
                        Failure(
                            message: "Invalid user ID",
                            errorType: .fetchError
                        )
                    )
                }

                let title =
                    conversationData["title"]?.stringValue ?? "New Conversation"

                let contextTypeString =
                    conversationData["context_type"]?.stringValue ?? "general"
                let contextType =
                    ContextType(rawValue: contextTypeString) ?? .general

                _ =
                    conversationData["session_id"]?.stringValue
                    ?? UUID().uuidString

                let sessionTypeString =
                    conversationData["session_type"]?.stringValue ?? "chat"
                let sessionType =
                    SessionType(rawValue: sessionTypeString) ?? .chat

                let isActive = conversationData["is_active"]?.boolValue ?? true

                // Simplified date parsing
                let createdAt =
                    DateParser.parseDate(from: conversationData["created_at"])
                    ?? Date()
                let updatedAt =
                    DateParser.parseDate(from: conversationData["updated_at"])
                    ?? Date()

                let conversation = ChatConversation(
                    id: conversationId,
                    userId: userIdString,
                    title: title,
                    contextType: contextType,
                    sessionContext: SessionContext(),
                    sessionType: sessionType,
                    isActive: isActive,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )

                print(
                    "🟢 ChatRepo Debug: Successfully created ChatConversation object"
                )
                return (conversation, nil)

            } catch {
                print(
                    "🔴 ChatRepo Debug: Attempt \(retryCount + 1) failed with error: \(error)"
                )

                // Check if it's a retryable error (including "Message too long")
                if shouldRetryError(error) {
                    print(
                        "🟡 ChatRepo Debug: Detected retryable error in fetchConversation, retrying with delay..."
                    )

                    retryCount += 1
                    if retryCount < maxRetries {
                        // Wait before retrying (exponential backoff)
                        let delay = Double(retryCount) * 0.5
                        try? await Task.sleep(
                            nanoseconds: UInt64(delay * 1_000_000_000)
                        )
                        continue
                    }
                } else {
                    print(
                        "🔴 ChatRepo Debug: Non-retryable error, failing immediately"
                    )
                }

                // For other errors or max retries reached
                return (
                    nil,
                    Failure(
                        message:
                            "Error fetching conversation: \(error.localizedDescription)",
                        errorType: .fetchError
                    )
                )
            }
        }

        return (
            nil,
            Failure(
                message:
                    "Failed to fetch conversation after \(maxRetries) attempts",
                errorType: .fetchError
            )
        )
    }

    /// Create a new conversation using the SQL function
    static func createConversation(
        request: CreateConversationRequest
    ) async -> (ChatConversation?, Failure?) {
        guard let userId = currentUserId else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: .authError
                )
            )
        }

        do {
            let encoder = JSONEncoder()
            let initialSessionContextData = try encoder.encode(
                request.initialSessionContext ?? SessionContext()
            )
            let initialSessionContextString =
                String(data: initialSessionContextData, encoding: .utf8) ?? "{}"

            let parameters: [String: String] = [
                "p_user_id": userId,
                "p_title": request.title ?? "New Conversation",
                "p_context_type": request.contextType?.rawValue ?? "general",
                "p_session_type": request.sessionType?.rawValue ?? "chat",
                "p_initial_session_context": initialSessionContextString,
            ]

            let response: UUID = try await supabase.rpc(
                "create_new_chat_session",
                params: parameters
            )
            .execute()
            .value

            // Fetch the created conversation
            return await fetchConversation(id: response)

        } catch {
            return (
                nil,
                Failure(
                    message:
                        "Error creating conversation: \(error.localizedDescription)",
                    errorType: .insertError
                )
            )
        }
    }

    /// Update conversation details
    static func updateConversation(
        id: UUID,
        title: String? = nil,
        isActive: Bool? = nil
    ) async -> (ChatConversation?, Failure?) {
        guard let userId = currentUserId else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: .authError
                )
            )
        }

        do {
            // Create a struct for the update to ensure proper encoding
            struct ConversationUpdate: Encodable {
                let title: String?
                let is_active: Bool?

                init(title: String?, isActive: Bool?) {
                    self.title = title
                    self.is_active = isActive
                }
            }

            let update = ConversationUpdate(title: title, isActive: isActive)

            let response: [ChatConversation] =
                try await supabase
                .from("chat_conversations")
                .update(update)
                .eq("id", value: id.uuidString)
                .eq("user_id", value: userId)
                .select()
                .execute()
                .value

            return (response.first, nil)

        } catch {
            return (
                nil,
                Failure(
                    message:
                        "Error updating conversation: \(error.localizedDescription)",
                    errorType: .updateError
                )
            )
        }
    }

    /// Update session context using the SQL function
    static func updateSessionContext(
        conversationId: UUID,
        sessionContext: SessionContext
    ) async -> (Bool, Failure?) {
        do {
            let encoder = JSONEncoder()
            let contextData = try encoder.encode(sessionContext)
            let contextString =
                String(data: contextData, encoding: .utf8) ?? "{}"

            let parameters: [String: String] = [
                "p_conversation_id": conversationId.uuidString,
                "p_context_updates": contextString,
            ]

            let response: Bool =
                try await supabase
                .rpc("update_session_context", params: parameters)
                .execute()
                .value

            return (response, nil)

        } catch {
            return (
                false,
                Failure(
                    message:
                        "Error updating session context: \(error.localizedDescription)",
                    errorType: .updateError
                )
            )
        }
    }

    /// Delete a conversation (soft delete by setting is_active to false)
    static func deleteConversation(id: UUID) async -> (Bool, Failure?) {
        return await updateConversation(id: id, isActive: false).0 != nil
            ? (true, nil)
            : (
                false,
                Failure(
                    message: "Failed to delete conversation",
                    errorType: .deleteError
                )
            )
    }

    // MARK: - Message Management

    /// Fetch messages for a conversation with retry logic
    static func fetchMessages(
        conversationId: UUID,
        pagination: PaginationRequest = PaginationRequest()
    ) async -> (PaginatedResponse<ChatMessage>?, Failure?) {
        guard let _ = currentUserId else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: .fetchError
                )
            )
        }

        print(
            "🟢 ChatRepo Debug: Fetching messages for conversation: \(conversationId)"
        )

        let maxRetries = 3
        var retryCount = 0

        while retryCount < maxRetries {
            do {
                let offset = (pagination.page - 1) * pagination.limit

                // Get total count with retry logic
                let countResponse: Int =
                    try await supabase
                    .from("chat_messages")
                    .select("*", head: true, count: .exact)
                    .eq("conversation_id", value: conversationId.uuidString)
                    .execute()
                    .count ?? 0

                print(
                    "🟢 ChatRepo Debug: Total messages count: \(countResponse)"
                )

                // Get paginated messages - simplified approach
                let response: [ChatMessage] =
                    try await supabase
                    .from("chat_messages")
                    .select("*")  // Using * instead of select() to reduce URL length
                    .eq("conversation_id", value: conversationId.uuidString)
                    .order("created_at", ascending: true)
                    .range(from: offset, to: offset + pagination.limit - 1)
                    .execute()
                    .value

                print(
                    "🟢 ChatRepo Debug: Successfully fetched \(response.count) messages"
                )

                let totalPages = Int(
                    ceil(Double(countResponse) / Double(pagination.limit))
                )
                let paginationInfo = PaginationInfo(
                    currentPage: pagination.page,
                    totalPages: totalPages,
                    totalItems: countResponse,
                    itemsPerPage: pagination.limit
                )

                let paginatedResponse = PaginatedResponse(
                    data: response,
                    pagination: paginationInfo
                )
                return (paginatedResponse, nil)

            } catch {
                print(
                    "🔴 ChatRepo Debug: Messages fetch attempt \(retryCount + 1) failed with error: \(error)"
                )

                // Handle retryable errors (including "Message too long")
                if shouldRetryError(error) {
                    print(
                        "🟡 ChatRepo Debug: Detected retryable error in fetchMessages, retrying..."
                    )

                    retryCount += 1
                    if retryCount < maxRetries {
                        // Brief delay before retry with exponential backoff
                        let delay = Double(retryCount) * 0.3
                        try? await Task.sleep(
                            nanoseconds: UInt64(delay * 1_000_000_000)
                        )
                        continue
                    }
                }

                // For other errors or max retries reached
                return (
                    nil,
                    Failure(
                        message:
                            "Error fetching messages: \(error.localizedDescription)",
                        errorType: .fetchError
                    )
                )
            }
        }

        return (
            nil,
            Failure(
                message:
                    "Failed to fetch messages after \(maxRetries) attempts",
                errorType: .fetchError
            )
        )
    }

    /// Send a new message with retry logic
    static func sendMessage(
        conversationId: UUID,
        content: String,
        role: MessageRole = .user,
        metadata: MessageMetadata? = nil
    ) async -> (ChatMessage?, Failure?) {
        guard let userId = currentUserId else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: .authError
                )
            )
        }

        print(
            "🟢 ChatRepo Debug: Sending message to conversation: \(conversationId)"
        )

        let maxRetries = 2
        var retryCount = 0

        while retryCount < maxRetries {
            do {
                let message = ChatMessage(
                    conversationId: conversationId,
                    userId: userId,
                    role: role,
                    content: content,
                    metadata: metadata
                )

                let response: [ChatMessage] =
                    try await supabase
                    .from("chat_messages")
                    .insert(message)
                    .select("*")
                    .execute()
                    .value

                print("🟢 ChatRepo Debug: Successfully sent message")
                return (response.first, nil)

            } catch {
                print(
                    "🔴 ChatRepo Debug: Send message attempt \(retryCount + 1) failed: \(error)"
                )

                if shouldRetryError(error) {
                    print(
                        "🟡 ChatRepo Debug: Detected retryable error in sendMessage, retrying..."
                    )

                    retryCount += 1
                    if retryCount < maxRetries {
                        let delay = Double(retryCount) * 0.3
                        try? await Task.sleep(
                            nanoseconds: UInt64(delay * 1_000_000_000)
                        )
                        continue
                    }
                }

                return (
                    nil,
                    Failure(
                        message:
                            "Error sending message: \(error.localizedDescription)",
                        errorType: .insertError
                    )
                )
            }
        }

        return (
            nil,
            Failure(
                message: "Failed to send message after \(maxRetries) attempts",
                errorType: .insertError
            )
        )
    }

    /// Update message content or metadata
    static func updateMessage(
        id: UUID,
        content: String? = nil,
        metadata: MessageMetadata? = nil,
        tokensUsed: Int? = nil,
        processingTimeMs: Int? = nil
    ) async -> (ChatMessage?, Failure?) {
        guard let userId = currentUserId else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: .authError
                )
            )
        }

        do {
            let update = MessageUpdate(
                content: content,
                metadata: metadata,
                tokensUsed: tokensUsed,
                processingTimeMs: processingTimeMs
            )

            let response: [ChatMessage] =
                try await supabase
                .from("chat_messages")
                .update(update)
                .eq("id", value: id.uuidString)
                .eq("user_id", value: userId)
                .select()
                .execute()
                .value

            return (response.first, nil)

        } catch {
            return (
                nil,
                Failure(
                    message:
                        "Error updating message: \(error.localizedDescription)",
                    errorType: .updateError
                )
            )
        }
    }

    /// Delete a message
    static func deleteMessage(id: UUID) async -> (Bool, Failure?) {
        guard let userId = currentUserId else {
            return (
                false,
                Failure(
                    message: "User not authenticated",
                    errorType: .authError
                )
            )
        }

        do {
            try await supabase
                .from("chat_messages")
                .delete()
                .eq("id", value: id.uuidString)
                .eq("user_id", value: userId)
                .execute()

            return (true, nil)

        } catch {
            return (
                false,
                Failure(
                    message:
                        "Error deleting message: \(error.localizedDescription)",
                    errorType: .deleteError
                )
            )
        }
    }

    static func deleteAllChat() async -> Failure? {
        guard let userId = currentUserId else {
            return Failure(
                message: "User not authenticated",
                errorType: .authError
            )
        }

        do {
            try await supabase
                .from("chat_conversations")
                .delete()
                .eq("user_id", value: userId)
                .execute()
            return nil
        } catch {
            return Failure(
                message:
                    "Error deleting all chat: \(error.localizedDescription)",
                errorType: .deleteError
            )
        }

    }

}
