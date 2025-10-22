//
//  ChatRepo.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//  Updated to use backend API on 10/21/25
//

import Foundation

class ChatRepo {
    private static let apiClient = Api.shared

    // MARK: - Conversation Management

    /// Fetch all conversations for the current user
    static func fetchConversations(
        pagination: PaginationRequest = PaginationRequest()
    ) async -> (PaginatedResponse<ConversationSummary>?, Failure?) {

        let (result, error) = await apiClient.sendRequest(
            path: AppEndpoints.conversations,
            method: .get,
            queryParameters: [
                "page": pagination.page,
                "limit": pagination.limit,
            ]
        )

        if let error = error {
            return (nil, error)
        }

        guard let resultDict = result as? [String: Any],
            let success = resultDict["success"] as? Bool,
            success == true,
            let dataArray = resultDict["data"] as? [[String: Any]],
            let paginationDict = resultDict["pagination"] as? [String: Any]
        else {
            return (
                nil,
                Failure(
                    message: "Invalid response format",
                    errorType: .parseError
                )
            )
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataArray)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let conversations = try decoder.decode(
                [ConversationSummary].self,
                from: jsonData
            )

            let paginationInfo = PaginationInfo(
                currentPage: paginationDict["page"] as? Int ?? pagination.page,
                totalPages: paginationDict["totalPages"] as? Int ?? 1,
                totalItems: paginationDict["total"] as? Int
                    ?? conversations.count,
                itemsPerPage: pagination.limit
            )

            let paginatedResponse = PaginatedResponse(
                data: conversations,
                pagination: paginationInfo
            )

            return (paginatedResponse, nil)
        } catch {
            return (
                nil,
                Failure(
                    message:
                        "Error parsing conversations: \(error.localizedDescription)",
                    errorType: .parseError
                )
            )
        }
    }

    /// Fetch a specific conversation by ID
    static func fetchConversation(id: UUID) async -> (
        ChatConversation?, Failure?
    ) {
        print("🟢 ChatRepo Debug: Fetching conversation with ID: \(id)")

        let (result, error) = await apiClient.sendRequest(
            path: AppEndpoints.conversationById(id: id.uuidString),
            method: .get
        )
        print(
            "result: \(String(describing: result)), error: \(String(describing: error))"
        )
        if let error = error {
            return (nil, error)
        }

        guard let resultDict = result as? [String: Any],
            let success = resultDict["success"] as? Bool,
            success == true,
            let conversationData = resultDict["data"] as? [String: Any]
        else {
            return (
                nil,
                Failure(
                    message: "Invalid response format",
                    errorType: .parseError
                )
            )
        }

        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: conversationData
            )
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let conversation = try decoder.decode(
                ChatConversation.self,
                from: jsonData
            )

            print("🟢 ChatRepo Debug: Successfully fetched conversation")
            return (conversation, nil)
        } catch {
            print("🔴 ChatRepo Debug: Error parsing conversation: \(error)")
            return (
                nil,
                Failure(
                    message:
                        "Error parsing conversation: \(error.localizedDescription)",
                    errorType: .parseError
                )
            )
        }
    }

    /// Create a new conversation
    static func createConversation(
        request: CreateConversationRequest
    ) async -> (ChatConversation?, Failure?) {

        let requestBody: [String: Any] = [
            "title": request.title ?? "New Conversation",
            "context_type": request.contextType?.rawValue ?? "general",
            "session_type": request.sessionType?.rawValue ?? "chat",
            "session_context": try? request.initialSessionContext?
                .toDictionary() ?? [:],
        ]

        let (result, error) = await apiClient.sendRequest(
            path: AppEndpoints.conversations,
            method: .post,
            body: requestBody
        )

        if let error = error {
            return (nil, error)
        }

        guard let resultDict = result as? [String: Any],
            let success = resultDict["success"] as? Bool,
            success == true,
            let conversationData = resultDict["data"] as? [String: Any]
        else {
            return (
                nil,
                Failure(
                    message: "Invalid response format",
                    errorType: .parseError
                )
            )
        }

        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: conversationData
            )
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let conversation = try decoder.decode(
                ChatConversation.self,
                from: jsonData
            )

            return (conversation, nil)
        } catch {
            return (
                nil,
                Failure(
                    message:
                        "Error parsing created conversation: \(error.localizedDescription)",
                    errorType: .parseError
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

        var requestBody: [String: Any] = [:]
        if let title = title {
            requestBody["title"] = title
        }
        if let isActive = isActive {
            requestBody["is_active"] = isActive
        }

        let (result, error) = await apiClient.sendRequest(
            path: AppEndpoints.conversationById(id: id.uuidString),
            method: .put,
            body: requestBody
        )

        if let error = error {
            return (nil, error)
        }

        guard let resultDict = result as? [String: Any],
            let success = resultDict["success"] as? Bool,
            success == true,
            let conversationData = resultDict["data"] as? [String: Any]
        else {
            return (
                nil,
                Failure(
                    message: "Invalid response format",
                    errorType: .parseError
                )
            )
        }

        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: conversationData
            )
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let conversation = try decoder.decode(
                ChatConversation.self,
                from: jsonData
            )

            return (conversation, nil)
        } catch {
            return (
                nil,
                Failure(
                    message:
                        "Error parsing updated conversation: \(error.localizedDescription)",
                    errorType: .parseError
                )
            )
        }
    }

    /// Update session context
    static func updateSessionContext(
        conversationId: UUID,
        sessionContext: SessionContext
    ) async -> (Bool, Failure?) {

        do {
            let contextDict = try sessionContext.toDictionary()
            print(
                "🟢 ChatRepo Debug: Updating session context with data: \(contextDict)"
            )

            let requestBody: [String: Any] = [
                "context_updates": contextDict
            ]

            let (result, error) = await apiClient.sendRequest(
                path: AppEndpoints.conversationContext(
                    id: conversationId.uuidString
                ),
                method: .put,
                body: requestBody
            )

            if let error = error {
                print(
                    "🔴 ChatRepo Debug: API error updating context: \(error.message)"
                )
                return (false, error)
            }

            guard let resultDict = result as? [String: Any],
                let success = resultDict["success"] as? Bool
            else {
                print(
                    "🔴 ChatRepo Debug: Invalid response format: \(String(describing: result))"
                )
                return (
                    false,
                    Failure(
                        message: "Invalid response format",
                        errorType: .parseError
                    )
                )
            }

            print(
                "🟢 ChatRepo Debug: Session context update success: \(success)"
            )
            return (success, nil)
        } catch {
            print("🔴 ChatRepo Debug: Error encoding session context: \(error)")
            return (
                false,
                Failure(
                    message:
                        "Error encoding session context: \(error.localizedDescription)",
                    errorType: .parseError
                )
            )
        }
    }

    /// Delete a conversation (soft delete by setting is_active to false)
    static func deleteConversation(id: UUID) async -> (Bool, Failure?) {
        let (conversation, error) = await updateConversation(
            id: id,
            isActive: false
        )
        if let error = error {
            return (false, error)
        }
        return (conversation != nil, nil)
    }

    // MARK: - Message Management

    /// Fetch messages for a conversation
    static func fetchMessages(
        conversationId: UUID,
        pagination: PaginationRequest = PaginationRequest()
    ) async -> (PaginatedResponse<ChatMessage>?, Failure?) {

        print(
            "🟢 ChatRepo Debug: Fetching messages for conversation: \(conversationId)"
        )

        let (result, error) = await apiClient.sendRequest(
            path: "/conversations/\(conversationId.uuidString)/messages",
            method: .get,
            queryParameters: [
                "page": pagination.page,
                "limit": pagination.limit,
            ]
        )

        if let error = error {
            return (nil, error)
        }

        guard let resultDict = result as? [String: Any],
            let success = resultDict["success"] as? Bool,
            success == true,
            let dataArray = resultDict["data"] as? [[String: Any]],
            let paginationDict = resultDict["pagination"] as? [String: Any]
        else {
            return (
                nil,
                Failure(
                    message: "Invalid response format",
                    errorType: .parseError
                )
            )
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataArray)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let messages = try decoder.decode(
                [ChatMessage].self,
                from: jsonData
            )

            let paginationInfo = PaginationInfo(
                currentPage: paginationDict["page"] as? Int ?? pagination.page,
                totalPages: paginationDict["totalPages"] as? Int ?? 1,
                totalItems: paginationDict["total"] as? Int ?? messages.count,
                itemsPerPage: pagination.limit
            )

            let paginatedResponse = PaginatedResponse(
                data: messages,
                pagination: paginationInfo
            )

            return (paginatedResponse, nil)
        } catch {
            return (
                nil,
                Failure(
                    message:
                        "Error parsing messages: \(error.localizedDescription)",
                    errorType: .parseError
                )
            )
        }
    }

    /// Send a new message
    static func sendMessage(
        conversationId: UUID,
        content: String,
        role: MessageRole = .user,
        metadata: MessageMetadata? = nil
    ) async -> (ChatMessage?, Failure?) {

        print(
            "🟢 ChatRepo Debug: Sending message to conversation: \(conversationId)"
        )

        var requestBody: [String: Any] = [
            "conversation_id": conversationId.uuidString,
            "role": role.rawValue,
            "content": content,
        ]

        if let metadata = metadata {
            requestBody["metadata"] = try? metadata.toDictionary()
        }

        let (result, error) = await apiClient.sendRequest(
            path: AppEndpoints.messages,
            method: .post,
            body: requestBody
        )

        if let error = error {
            return (nil, error)
        }

        guard let resultDict = result as? [String: Any],
            let success = resultDict["success"] as? Bool,
            success == true,
            let messageData = resultDict["data"] as? [String: Any]
        else {
            return (
                nil,
                Failure(
                    message: "Invalid response format",
                    errorType: .parseError
                )
            )
        }

        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: messageData
            )
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let message = try decoder.decode(ChatMessage.self, from: jsonData)

            return (message, nil)
        } catch {
            return (
                nil,
                Failure(
                    message:
                        "Error parsing sent message: \(error.localizedDescription)",
                    errorType: .parseError
                )
            )
        }
    }

    /// Update message content or metadata
    static func updateMessage(
        id: UUID,
        content: String? = nil,
        metadata: MessageMetadata? = nil,
        tokensUsed: Int? = nil,
        processingTimeMs: Int? = nil
    ) async -> (ChatMessage?, Failure?) {

        var requestBody: [String: Any] = [:]
        if let content = content {
            requestBody["content"] = content
        }
        if let metadata = metadata {
            requestBody["metadata"] = try? metadata.toDictionary()
        }
        if let tokensUsed = tokensUsed {
            requestBody["tokens_used"] = tokensUsed
        }
        if let processingTimeMs = processingTimeMs {
            requestBody["processing_time_ms"] = processingTimeMs
        }

        let (result, error) = await apiClient.sendRequest(
            path: AppEndpoints.messageById(id: id.uuidString),
            method: .put,
            body: requestBody
        )

        if let error = error {
            return (nil, error)
        }

        guard let resultDict = result as? [String: Any],
            let success = resultDict["success"] as? Bool,
            success == true,
            let messageData = resultDict["data"] as? [String: Any]
        else {
            return (
                nil,
                Failure(
                    message: "Invalid response format",
                    errorType: .parseError
                )
            )
        }

        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: messageData
            )
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let message = try decoder.decode(ChatMessage.self, from: jsonData)

            return (message, nil)
        } catch {
            return (
                nil,
                Failure(
                    message:
                        "Error parsing updated message: \(error.localizedDescription)",
                    errorType: .parseError
                )
            )
        }
    }

    /// Delete a message
    static func deleteMessage(id: UUID) async -> (Bool, Failure?) {
        let (result, error) = await apiClient.sendRequest(
            path: AppEndpoints.messageById(id: id.uuidString),
            method: .delete
        )

        if let error = error {
            return (false, error)
        }

        guard let resultDict = result as? [String: Any],
            let success = resultDict["success"] as? Bool
        else {
            return (
                false,
                Failure(
                    message: "Invalid response format",
                    errorType: .parseError
                )
            )
        }

        return (success, nil)
    }

    /// Delete all chats for the current user
    static func deleteAllChat() async -> Failure? {
        // This would need to be implemented on the backend as a bulk delete endpoint
        // For now, we'll return an error indicating this is not implemented
        return Failure(
            message: "Delete all chats not implemented via API",
            errorType: .unKnownError
        )
    }
}

// MARK: - Helper Extensions

extension SessionContext {
    func toDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        let dict =
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return dict ?? [:]
    }
}

extension MessageMetadata {
    func toDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        let dict =
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return dict ?? [:]
    }
}
