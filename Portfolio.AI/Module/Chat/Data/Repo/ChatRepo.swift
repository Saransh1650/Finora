//
//  ChatRepo.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import Foundation
import Supabase

// Simplified conversation model for database queries (avoiding JSONB complexity)
private struct SimplifiedConversation: Codable {
    let id: UUID
    let userId: String
    let title: String
    let contextType: String  // Changed to String to avoid enum decoding issues
    let sessionId: String
    let sessionType: String  // Changed to String to avoid enum decoding issues
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case contextType = "context_type"
        case sessionId = "session_id"
        case sessionType = "session_type"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// AnyJSON helper for handling dynamic JSON responses (kept for other methods)
extension AnyJSON {
    var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        default:
            return nil
        }
    }
    
    var boolValue: Bool? {
        switch self {
        case .bool(let value):
            return value
        default:
            return nil
        }
    }
}


class ChatRepo {
    static private let supabase = SupabaseManager.shared.client
    
    static private var currentUserId: String? {
        supabase.auth.currentUser?.id.uuidString
    }
    
    // MARK: - Conversation Management
    
    /// Fetch all conversations for the current user (simplified approach)
    static func fetchConversations(
        pagination: PaginationRequest = PaginationRequest()
    ) async -> (PaginatedResponse<ConversationSummary>?, Failure?) {
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .fetchError))
        }
        
        print("🟢 ChatRepo Debug: Starting fetchConversations for userId: \(userId)")
        
        do {
            let offset = (pagination.page - 1) * pagination.limit
            
            // Get total count first
            let countResponse: Int = try await supabase
                .from("chat_conversations")
                .select("*", head: true, count: .exact)
                .eq("user_id", value: userId)
                .eq("is_active", value: true)
                .execute()
                .count ?? 0
            
            print("🟢 ChatRepo Debug: Total active conversations count: \(countResponse)")
            
            // Try the most basic query first - just get raw data
            let rawResponse: [[String: AnyJSON]] = try await supabase
                .from("chat_conversations")
                .select("id,user_id,title,context_type,session_id,session_type,is_active,created_at,updated_at")
                .eq("user_id", value: userId)
                .eq("is_active", value: true)
                .order("updated_at", ascending: false)
                .range(from: offset, to: offset + pagination.limit - 1)
                .execute()
                .value
            
            print("🟢 ChatRepo Debug: Raw response count: \(rawResponse.count)")
            if let firstItem = rawResponse.first {
                print("🟢 ChatRepo Debug: First item keys: \(firstItem.keys)")
                print("🟢 ChatRepo Debug: First item: \(firstItem)")
            }
            
            // Convert manually with lots of error checking
            let conversations: [ConversationSummary] = rawResponse.compactMap { row in
                do {
                    guard let idString = row["id"]?.stringValue,
                          let id = UUID(uuidString: idString) else {
                        print("🔴 ChatRepo Debug: Failed to parse ID from: \(row["id"] ?? "nil")")
                        return nil
                    }
                    
                    guard let userIdString = row["user_id"]?.stringValue else {
                        print("🔴 ChatRepo Debug: Failed to parse user_id")
                        return nil
                    }
                    
                    guard let title = row["title"]?.stringValue else {
                        print("🔴 ChatRepo Debug: Failed to parse title")
                        return nil
                    }
                    
                    let contextTypeString = row["context_type"]?.stringValue ?? "general"
                    let contextType = ContextType(rawValue: contextTypeString) ?? .general
                    
                    let sessionId = row["session_id"]?.stringValue ?? UUID().uuidString
                    
                    let sessionTypeString = row["session_type"]?.stringValue ?? "chat"
                    let sessionType = SessionType(rawValue: sessionTypeString) ?? .chat
                    
                    let isActive = row["is_active"]?.boolValue ?? true
                    
                    // Handle dates with multiple formats
                    let createdAt: Date
                    let updatedAt: Date
                    
                    if let createdAtString = row["created_at"]?.stringValue {
                        let iso8601Formatter = ISO8601DateFormatter()
                        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        
                        if let date = iso8601Formatter.date(from: createdAtString) {
                            createdAt = date
                        } else {
                            // Try without fractional seconds
                            iso8601Formatter.formatOptions = [.withInternetDateTime]
                            createdAt = iso8601Formatter.date(from: createdAtString) ?? Date()
                        }
                    } else {
                        createdAt = Date()
                    }
                    
                    if let updatedAtString = row["updated_at"]?.stringValue {
                        let iso8601Formatter = ISO8601DateFormatter()
                        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        
                        if let date = iso8601Formatter.date(from: updatedAtString) {
                            updatedAt = date
                        } else {
                            // Try without fractional seconds
                            iso8601Formatter.formatOptions = [.withInternetDateTime]
                            updatedAt = iso8601Formatter.date(from: updatedAtString) ?? Date()
                        }
                    } else {
                        updatedAt = Date()
                    }
                    
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
                } catch {
                    print("🔴 ChatRepo Debug: Error processing row: \(error)")
                    return nil
                }
            }
            
            print("🟢 ChatRepo Debug: Successfully converted \(conversations.count) conversations")
            
            let totalPages = Int(ceil(Double(countResponse) / Double(pagination.limit)))
            let paginationInfo = PaginationInfo(
                currentPage: pagination.page,
                totalPages: totalPages,
                totalItems: countResponse,
                itemsPerPage: pagination.limit
            )
            
            let paginatedResponse = PaginatedResponse(data: conversations, pagination: paginationInfo)
            return (paginatedResponse, nil)
            
        } catch {
            print("🔴 ChatRepo Debug: Detailed error: \(error)")
            if let decodingError = error as? DecodingError {
                print("🔴 ChatRepo Debug: Decoding error details: \(decodingError)")
            }
            return (nil, Failure(message: "Error fetching conversations: \(error.localizedDescription)", errorType: .fetchError))
        }
    }
    
    /// Fetch a specific conversation by ID
    static func fetchConversation(id: UUID) async -> (ChatConversation?, Failure?) {
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .fetchError))
        }
        
        print("🟢 ChatRepo Debug: Fetching conversation with ID: \(id)")
        
        do {
            // Use the same raw JSON approach to avoid decoding issues
            let rawResponse: [[String: AnyJSON]] = try await supabase
                .from("chat_conversations")
                .select("id,user_id,title,context_type,session_id,session_type,is_active,created_at,updated_at")
                .eq("id", value: id.uuidString)
                .eq("user_id", value: userId)
                .limit(1)
                .execute()
                .value
            
            print("🟢 ChatRepo Debug: Raw conversation response count: \(rawResponse.count)")
            
            guard let conversationData = rawResponse.first else {
                print("🔴 ChatRepo Debug: No conversation found with ID: \(id)")
                return (nil, Failure(message: "Conversation not found", errorType: .fetchError))
            }
            
            print("🟢 ChatRepo Debug: Found conversation data: \(conversationData)")
            
            // Manually construct ChatConversation
            guard let idString = conversationData["id"]?.stringValue,
                  let conversationId = UUID(uuidString: idString),
                  let userIdString = conversationData["user_id"]?.stringValue,
                  let title = conversationData["title"]?.stringValue else {
                print("🔴 ChatRepo Debug: Failed to parse basic conversation fields")
                return (nil, Failure(message: "Invalid conversation data", errorType: .fetchError))
            }
            
            let contextTypeString = conversationData["context_type"]?.stringValue ?? "general"
            let contextType = ContextType(rawValue: contextTypeString) ?? .general
            
            let sessionId = conversationData["session_id"]?.stringValue ?? UUID().uuidString
            
            let sessionTypeString = conversationData["session_type"]?.stringValue ?? "chat"
            let sessionType = SessionType(rawValue: sessionTypeString) ?? .chat
            
            let isActive = conversationData["is_active"]?.boolValue ?? true
            
            // Handle dates
            let createdAt: Date
            let updatedAt: Date
            
            if let createdAtString = conversationData["created_at"]?.stringValue {
                let iso8601Formatter = ISO8601DateFormatter()
                iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                if let date = iso8601Formatter.date(from: createdAtString) {
                    createdAt = date
                } else {
                    iso8601Formatter.formatOptions = [.withInternetDateTime]
                    createdAt = iso8601Formatter.date(from: createdAtString) ?? Date()
                }
            } else {
                createdAt = Date()
            }
            
            if let updatedAtString = conversationData["updated_at"]?.stringValue {
                let iso8601Formatter = ISO8601DateFormatter()
                iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                if let date = iso8601Formatter.date(from: updatedAtString) {
                    updatedAt = date
                } else {
                    iso8601Formatter.formatOptions = [.withInternetDateTime]
                    updatedAt = iso8601Formatter.date(from: updatedAtString) ?? Date()
                }
            } else {
                updatedAt = Date()
            }
            
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
            
            print("🟢 ChatRepo Debug: Successfully created ChatConversation object")
            return (conversation, nil)
            
        } catch {
            print("🔴 ChatRepo Debug: Error fetching conversation: \(error)")
            return (nil, Failure(message: "Error fetching conversation: \(error.localizedDescription)", errorType: .fetchError))
        }
    }
    
    /// Create a new conversation using the SQL function
    static func createConversation(
        request: CreateConversationRequest
    ) async -> (ChatConversation?, Failure?) {
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .authError))
        }
        
        do {
            let encoder = JSONEncoder()
            let initialSessionContextData = try encoder.encode(request.initialSessionContext ?? SessionContext())
            let initialSessionContextString = String(data: initialSessionContextData, encoding: .utf8) ?? "{}"
            
            let parameters: [String: String] = [
                "p_user_id": userId,
                "p_title": request.title ?? "New Conversation",
                "p_context_type": request.contextType?.rawValue ?? "general",
                "p_session_type": request.sessionType?.rawValue ?? "chat",
                "p_initial_session_context": initialSessionContextString
            ]
            
            let response: UUID = try await supabase.rpc("create_new_chat_session", params: parameters)
                .execute()
                .value
            
            // Fetch the created conversation
            return await fetchConversation(id: response)
            
        } catch {
            return (nil, Failure(message: "Error creating conversation: \(error.localizedDescription)", errorType: .insertError))
        }
    }
    
    /// Update conversation details
    static func updateConversation(
        id: UUID,
        title: String? = nil,
        isActive: Bool? = nil
    ) async -> (ChatConversation?, Failure?) {
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .authError))
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
            
            let response: [ChatConversation] = try await supabase
                .from("chat_conversations")
                .update(update)
                .eq("id", value: id.uuidString)
                .eq("user_id", value: userId)
                .select()
                .execute()
                .value
            
            return (response.first, nil)
            
        } catch {
            return (nil, Failure(message: "Error updating conversation: \(error.localizedDescription)", errorType: .updateError))
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
            let contextString = String(data: contextData, encoding: .utf8) ?? "{}"
            
            let parameters: [String: String] = [
                "p_conversation_id": conversationId.uuidString,
                "p_context_updates": contextString
            ]
            
            let response: Bool = try await supabase
                .rpc("update_session_context", params: parameters)
                .execute()
                .value
            
            return (response, nil)
            
        } catch {
            return (false, Failure(message: "Error updating session context: \(error.localizedDescription)", errorType: .updateError))
        }
    }
    
    /// Delete a conversation (soft delete by setting is_active to false)
    static func deleteConversation(id: UUID) async -> (Bool, Failure?) {
        return await updateConversation(id: id, isActive: false).0 != nil ? (true, nil) : (false, Failure(message: "Failed to delete conversation", errorType: .deleteError))
    }
    
    // MARK: - Message Management
    
    /// Fetch messages for a conversation
    static func fetchMessages(
        conversationId: UUID,
        pagination: PaginationRequest = PaginationRequest()
    ) async -> (PaginatedResponse<ChatMessage>?, Failure?) {
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .fetchError))
        }
        
        do {
            let offset = (pagination.page - 1) * pagination.limit
            
            // Get total count
            let countResponse: Int = try await supabase
                .from("chat_messages")
                .select("*", head: true, count: .exact)
                .eq("conversation_id", value: conversationId.uuidString)
                .execute()
                .count ?? 0
            
            // Get paginated messages
            let response: [ChatMessage] = try await supabase
                .from("chat_messages")
                .select()
                .eq("conversation_id", value: conversationId.uuidString)
                .order("created_at", ascending: true)
                .range(from: offset, to: offset + pagination.limit - 1)
                .execute()
                .value
            
            let totalPages = Int(ceil(Double(countResponse) / Double(pagination.limit)))
            let paginationInfo = PaginationInfo(
                currentPage: pagination.page,
                totalPages: totalPages,
                totalItems: countResponse,
                itemsPerPage: pagination.limit
            )
            
            let paginatedResponse = PaginatedResponse(data: response, pagination: paginationInfo)
            return (paginatedResponse, nil)
            
        } catch {
            return (nil, Failure(message: "Error fetching messages: \(error.localizedDescription)", errorType: .fetchError))
        }
    }
    
    /// Send a new message
    static func sendMessage(
        conversationId: UUID,
        content: String,
        role: MessageRole = .user,
        metadata: MessageMetadata? = nil
    ) async -> (ChatMessage?, Failure?) {
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .authError))
        }
        
        do {
            let message = ChatMessage(
                conversationId: conversationId,
                userId: userId,
                role: role,
                content: content,
                metadata: metadata
            )
            
            let response: [ChatMessage] = try await supabase
                .from("chat_messages")
                .insert(message)
                .select()
                .execute()
                .value
            
            return (response.first, nil)
            
        } catch {
            return (nil, Failure(message: "Error sending message: \(error.localizedDescription)", errorType: .insertError))
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
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .authError))
        }
        
        do {
            // Create a struct for the update to ensure proper encoding
            struct MessageUpdate: Encodable {
                let content: String?
                let metadata: MessageMetadata?
                let tokens_used: Int?
                let processing_time_ms: Int?
                
                init(content: String?, metadata: MessageMetadata?, tokensUsed: Int?, processingTimeMs: Int?) {
                    self.content = content
                    self.metadata = metadata
                    self.tokens_used = tokensUsed
                    self.processing_time_ms = processingTimeMs
                }
            }
            
            let update = MessageUpdate(
                content: content,
                metadata: metadata,
                tokensUsed: tokensUsed,
                processingTimeMs: processingTimeMs
            )
            
            let response: [ChatMessage] = try await supabase
                .from("chat_messages")
                .update(update)
                .eq("id", value: id.uuidString)
                .eq("user_id", value: userId)
                .select()
                .execute()
                .value
            
            return (response.first, nil)
            
        } catch {
            return (nil, Failure(message: "Error updating message: \(error.localizedDescription)", errorType: .updateError))
        }
    }
    
    /// Delete a message
    static func deleteMessage(id: UUID) async -> (Bool, Failure?) {
        guard let userId = currentUserId else {
            return (false, Failure(message: "User not authenticated", errorType: .authError))
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
            return (false, Failure(message: "Error deleting message: \(error.localizedDescription)", errorType: .deleteError))
        }
    }
    

   
}
