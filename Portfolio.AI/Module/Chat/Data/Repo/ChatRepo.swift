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
    
    // MARK: - Conversation Management
    
    /// Fetch all conversations for the current user
    static func fetchConversations(
        pagination: PaginationRequest = PaginationRequest()
    ) async -> (PaginatedResponse<ConversationSummary>?, Failure?) {
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .fetchError))
        }
        
        do {
            let offset = (pagination.page - 1) * pagination.limit
            
            // Get total count first
            let countResponse: Int = try await supabase
                .from("conversation_summaries")
                .select("*", head: true, count: .exact)
                .eq("user_id", value: userId)
                .execute()
                .count ?? 0
            
            // Get paginated data
            let response: [ConversationSummary] = try await supabase
                .from("conversation_summaries")
                .select()
                .eq("user_id", value: userId)
                .order("updated_at", ascending: false)
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
            return (nil, Failure(message: "Error fetching conversations: \(error.localizedDescription)", errorType: .fetchError))
        }
    }
    
    /// Fetch a specific conversation by ID
    static func fetchConversation(id: UUID) async -> (ChatConversation?, Failure?) {
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .fetchError))
        }
        
        do {
            let response: [ChatConversation] = try await supabase
                .from("chat_conversations")
                .select()
                .eq("id", value: id.uuidString)
                .eq("user_id", value: userId)
                .execute()
                .value
            
            return (response.first, nil)
            
        } catch {
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
                "p_include_portfolio_context": String(request.includePortfolioContext ?? true),
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
