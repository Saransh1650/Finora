//
//  ChatSearchAndAnalyticsRepo.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 20/9/25.
//

import Foundation
import Supabase

class ChatSearchAndAnalyticsRepo{

    static private let supabase = SupabaseManager.shared.client
    
    static private var currentUserId: String? {
        supabase.auth.currentUser?.id.uuidString
    }

    // MARK: - Search and Analytics
    
    /// Search messages across conversations
    static func searchMessages(
        query: String,
        conversationId: UUID? = nil,
        pagination: PaginationRequest = PaginationRequest()
    ) async -> (PaginatedResponse<ChatMessage>?, Failure?) {
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .fetchError))
        }
        
        do {
            let offset = (pagination.page - 1) * pagination.limit
            
            var baseQuery = supabase
                .from("chat_messages")
                .select()
                .eq("user_id", value: userId)
                .ilike("content", pattern: "%\(query)%")
            
            if let conversationId = conversationId {
                baseQuery = baseQuery.eq("conversation_id", value: conversationId.uuidString)
            }
            
            // Get count
            let countResponse: Int = try await supabase
                .from("chat_messages")
                .select("*", head: true, count: .exact)
                .eq("user_id", value: userId)
                .ilike("content", pattern: "%\(query)%")
                .execute()
                .count ?? 0
            
            // Get paginated results
            let response: [ChatMessage] = try await baseQuery
                .order("created_at", ascending: false)
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
            return (nil, Failure(message: "Error searching messages: \(error.localizedDescription)", errorType: .fetchError))
        }
    }
    
    /// Get conversation statistics
    static func getConversationStats(conversationId: UUID) async -> ([String: String]?, Failure?) {
        guard let userId = currentUserId else {
            return (nil, Failure(message: "User not authenticated", errorType: .fetchError))
        }
        
        do {
            let messages: [ChatMessage] = try await supabase
                .from("chat_messages")
                .select()
                .eq("conversation_id", value: conversationId.uuidString)
                .execute()
                .value
            
            let userMessages = messages.filter { $0.role == .user }
            let assistantMessages = messages.filter { $0.role == .assistant }
            let totalTokens = messages.reduce(0) { $0 + $1.tokensUsed }
            let avgProcessingTime = assistantMessages.isEmpty ? 0 : assistantMessages.reduce(0) { $0 + $1.processingTimeMs } / assistantMessages.count
            
            let formatter = ISO8601DateFormatter()
            
            let totalMessages = String(messages.count)
            let userMessagesCount = String(userMessages.count)
            let assistantMessagesCount = String(assistantMessages.count)
            let totalTokensStr = String(totalTokens)
            let avgProcessingTimeStr = String(avgProcessingTime)
            let firstMessageDateStr = messages.first?.createdAt != nil ? formatter.string(from: messages.first!.createdAt) : ""
            let lastMessageDateStr = messages.last?.createdAt != nil ? formatter.string(from: messages.last!.createdAt) : ""
            
            let stats: [String: String] = [
                "total_messages": totalMessages,
                "user_messages": userMessagesCount,
                "assistant_messages": assistantMessagesCount,
                "total_tokens": totalTokensStr,
                "avg_processing_time_ms": avgProcessingTimeStr,
                "first_message_date": firstMessageDateStr,
                "last_message_date": lastMessageDateStr
            ]
            
            return (stats, nil)
            
        } catch {
            return (nil, Failure(message: "Error getting conversation stats: \(error.localizedDescription)", errorType: .fetchError))
        }
    }
}
