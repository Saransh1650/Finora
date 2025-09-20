//
//  ChatErrorHandler.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import Foundation

// MARK: - Chat Specific Error Types

enum ChatErrorCode: String, CaseIterable {
    case conversationNotFound = "CONVERSATION_NOT_FOUND"
    case messageNotFound = "MESSAGE_NOT_FOUND"
    case attachmentNotFound = "ATTACHMENT_NOT_FOUND"
    case invalidSessionContext = "INVALID_SESSION_CONTEXT"
    case maxMessagesExceeded = "MAX_MESSAGES_EXCEEDED"
    case maxAttachmentsExceeded = "MAX_ATTACHMENTS_EXCEEDED"
    case invalidFileFormat = "INVALID_FILE_FORMAT"
    case fileTooLarge = "FILE_TOO_LARGE"
    case storageQuotaExceeded = "STORAGE_QUOTA_EXCEEDED"
    case tokenLimitExceeded = "TOKEN_LIMIT_EXCEEDED"
    case rateLimitExceeded = "RATE_LIMIT_EXCEEDED"
    case sessionExpired = "SESSION_EXPIRED"
    case invalidPortfolioContext = "INVALID_PORTFOLIO_CONTEXT"
    case aiServiceUnavailable = "AI_SERVICE_UNAVAILABLE"
    case messageGenerationFailed = "MESSAGE_GENERATION_FAILED"
    case attachmentProcessingFailed = "ATTACHMENT_PROCESSING_FAILED"
}

// MARK: - Chat Error Model

struct ChatErrorDetails {
    let code: ChatErrorCode
    let message: String
    let userMessage: String
    let suggestions: [String]
    let retryable: Bool
    
    init(
        code: ChatErrorCode,
        message: String,
        userMessage: String? = nil,
        suggestions: [String] = [],
        retryable: Bool = false
    ) {
        self.code = code
        self.message = message
        self.userMessage = userMessage ?? message
        self.suggestions = suggestions
        self.retryable = retryable
    }
}

// MARK: - Chat Error Handler

class ChatErrorHandler {
    
    static func handleError(_ error: Error) -> ChatErrorDetails {
        // Handle different types of errors
        if let failure = error as? Failure {
            return handleFailure(failure)
        } else if let chatError = error as? ChatError {
            return handleChatError(chatError)
        } else {
            return handleGenericError(error)
        }
    }
    
    private static func handleFailure(_ failure: Failure) -> ChatErrorDetails {
        switch failure.errorType {
        case .fetchError:
            return ChatErrorDetails(
                code: .conversationNotFound,
                message: failure.message ?? "",
                userMessage: "Unable to load your conversations. Please try again.",
                suggestions: ["Check your internet connection", "Pull to refresh"],
                retryable: true
            )
            
        case .insertError:
            return ChatErrorDetails(
                code: .messageGenerationFailed,
                message: failure.message ?? "",
                userMessage: "Failed to send your message. Please try again.",
                suggestions: ["Check your message content", "Try again in a moment"],
                retryable: true
            )
            
        case .updateError:
            return ChatErrorDetails(
                code: .invalidSessionContext,
                message: failure.message ?? "",
                userMessage: "Failed to update conversation. Please try again.",
                suggestions: ["Refresh the conversation", "Try again"],
                retryable: true
            )
            
        case .deleteError:
            return ChatErrorDetails(
                code: .conversationNotFound,
                message: failure.message ?? "",
                userMessage: "Failed to delete. The item may have already been removed.",
                suggestions: ["Refresh the list", "Try again"],
                retryable: false
            )
            
        case .authError:
            return ChatErrorDetails(
                code: .sessionExpired,
                message: failure.message ?? "",
                userMessage: "Your session has expired. Please sign in again.",
                suggestions: ["Sign in again", "Restart the app"],
                retryable: false
            )
            
        case .validationError:
            return ChatErrorDetails(
                code: .invalidFileFormat,
                message: failure.message ?? "",
                userMessage: failure.message,
                suggestions: ["Check file format and size", "Use a different file"],
                retryable: false
            )
            
        case .fileUploadError:
            return ChatErrorDetails(
                code: .attachmentProcessingFailed,
                message: failure.message ?? "",
                userMessage: "Failed to upload attachment. Please try again.",
                suggestions: ["Check file size", "Try a different file", "Check internet connection"],
                retryable: true
            )
            
        case .fileSizeError:
            return ChatErrorDetails(
                code: .fileTooLarge,
                message: failure.message ?? "",
                userMessage: "File is too large. Please use a smaller file.",
                suggestions: ["Compress the file", "Use a different file"],
                retryable: false
            )
            
        case .networkError:
            return ChatErrorDetails(
                code: .aiServiceUnavailable,
                message: failure.message ?? "",
                userMessage: "Unable to connect. Please check your internet connection.",
                suggestions: ["Check internet connection", "Try again later"],
                retryable: true
            )
            
        default:
            return ChatErrorDetails(
                code: .messageGenerationFailed,
                message: failure.message ?? "",
                userMessage: "Something went wrong. Please try again.",
                suggestions: ["Try again", "Restart the app"],
                retryable: true
            )
        }
    }
    
    private static func handleChatError(_ chatError: ChatError) -> ChatErrorDetails {
        guard let code = ChatErrorCode(rawValue: chatError.code) else {
            return ChatErrorDetails(
                code: .messageGenerationFailed,
                message: chatError.message,
                userMessage: chatError.message,
                retryable: false
            )
        }
        
        return getErrorDetails(for: code, message: chatError.message)
    }
    
    private static func handleGenericError(_ error: Error) -> ChatErrorDetails {
        return ChatErrorDetails(
            code: .messageGenerationFailed,
            message: error.localizedDescription,
            userMessage: "An unexpected error occurred. Please try again.",
            suggestions: ["Try again", "Restart the app"],
            retryable: true
        )
    }
    
    private static func getErrorDetails(for code: ChatErrorCode, message: String) -> ChatErrorDetails {
        switch code {
        case .conversationNotFound:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Conversation not found. It may have been deleted.",
                suggestions: ["Go back to conversations list", "Create a new conversation"],
                retryable: false
            )
            
        case .messageNotFound:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Message not found. It may have been deleted.",
                suggestions: ["Refresh the conversation"],
                retryable: false
            )
            
        case .attachmentNotFound:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Attachment not found. It may have been removed.",
                suggestions: ["Try uploading again"],
                retryable: false
            )
            
        case .invalidSessionContext:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Session context is invalid. Please refresh the conversation.",
                suggestions: ["Refresh conversation", "Start a new conversation"],
                retryable: true
            )
            
        case .maxMessagesExceeded:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "You've reached the maximum number of messages for this conversation.",
                suggestions: ["Start a new conversation", "Delete some old messages"],
                retryable: false
            )
            
        case .maxAttachmentsExceeded:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Too many attachments. Please remove some before adding more.",
                suggestions: ["Remove existing attachments", "Start a new conversation"],
                retryable: false
            )
            
        case .invalidFileFormat:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "File format not supported. Please use a different file type.",
                suggestions: ["Check supported file types", "Convert to a supported format"],
                retryable: false
            )
            
        case .fileTooLarge:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "File is too large. Please use a smaller file.",
                suggestions: ["Compress the file", "Use a different file"],
                retryable: false
            )
            
        case .storageQuotaExceeded:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Storage quota exceeded. Please delete some files.",
                suggestions: ["Delete old attachments", "Upgrade your plan"],
                retryable: false
            )
            
        case .tokenLimitExceeded:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Message is too long. Please shorten your message.",
                suggestions: ["Use shorter messages", "Break into multiple messages"],
                retryable: false
            )
            
        case .rateLimitExceeded:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "You're sending messages too quickly. Please wait a moment.",
                suggestions: ["Wait a few seconds", "Slow down message sending"],
                retryable: true
            )
            
        case .sessionExpired:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Your session has expired. Please sign in again.",
                suggestions: ["Sign in again", "Restart the app"],
                retryable: false
            )
            
        case .invalidPortfolioContext:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Portfolio context is invalid. Portfolio features may not work correctly.",
                suggestions: ["Refresh portfolio data", "Go to Portfolio section"],
                retryable: true
            )
            
        case .aiServiceUnavailable:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "AI service is currently unavailable. Please try again later.",
                suggestions: ["Try again in a few minutes", "Check service status"],
                retryable: true
            )
            
        case .messageGenerationFailed:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Failed to generate response. Please try again.",
                suggestions: ["Try rephrasing your message", "Try again", "Start a new conversation"],
                retryable: true
            )
            
        case .attachmentProcessingFailed:
            return ChatErrorDetails(
                code: code,
                message: message,
                userMessage: "Failed to process attachment. Please try again.",
                suggestions: ["Try uploading again", "Use a different file", "Check file format"],
                retryable: true
            )
        }
    }
}

// MARK: - Extensions

extension ChatErrorDetails {
    var shouldShowRetryButton: Bool {
        return retryable
    }
    
    var suggestionsText: String {
        return suggestions.joined(separator: " • ")
    }
    
    var isRecoverable: Bool {
        return ![.sessionExpired, .storageQuotaExceeded, .maxMessagesExceeded].contains(code)
    }
}
