//
//  ChatModule.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import Foundation

/**
 # Chat Module - Portfolio.AI
 
 ## Overview
 This module provides a comprehensive chat system with session management, portfolio context integration,
 and file attachment support. It's designed to work seamlessly with the updated database schema that
 includes session context tracking and portfolio integration.
 
 ## Architecture
 
 ### Models (Data/Models/)
 - **ChatConversation**: Main conversation model with session context, portfolio context, and metadata
 - **ChatMessage**: Individual message model with role, content, metadata, and performance tracking
 - **ChatAttachment**: File attachment model with validation, processing status, and metadata
 - **ChatPreviewData**: Response models, pagination, and preview data for UI
 
 ### Repository (Data/Repo/)
 - **ChatRepo**: Comprehensive data access layer with CRUD operations for conversations, messages, and attachments
 - Supports pagination, search, analytics, and session management
 - Integrates with Supabase database and storage
 
 ### Manager (Managers/)
 - **ChatManager**: Observable business logic layer for SwiftUI
 - Handles state management, real-time updates, and user interactions
 - Provides session context tracking and portfolio integration
 
 ### Utilities (Utils/)
 - **ChatErrorHandler**: Comprehensive error handling with user-friendly messages and recovery suggestions
 - Maps technical errors to actionable user guidance
 
 ## Key Features
 
 ### 1. Session Management
 - **Session Context**: Tracks conversation flow, user intent, and contextual data
 - **Session Types**: Chat, Analysis, Planning, Research modes
 - **Context Updates**: Real-time session context updates based on conversation flow
 
 ### 2. Portfolio Integration
 - **Portfolio Context**: Optional portfolio data integration (default: enabled)
 - **Portfolio Summary**: Includes stock data, investments, and analysis results
 - **Context-Aware Responses**: AI can access portfolio information when enabled
 
 ### 3. File Attachments
 - **Multiple File Types**: Images, documents, PDFs, CSV, JSON, text files
 - **Validation**: File size and type validation before upload
 - **Processing**: Status tracking for file processing and analysis
 - **Storage**: Supabase storage integration with unique file paths
 
 ### 4. Message Management
 - **Role-Based Messages**: User, Assistant, System message types
 - **Metadata**: Rich metadata for message context and AI parameters
 - **Performance Tracking**: Token usage and processing time tracking
 - **Search**: Full-text search across conversations and messages
 
 ### 5. Real-Time Features
 - **Live Updates**: Real-time conversation and message updates
 - **Pagination**: Efficient loading of large conversation histories
 - **Status Tracking**: Message and attachment status indicators
 
 ### 6. Error Handling
 - **User-Friendly Errors**: Technical errors translated to actionable messages
 - **Recovery Suggestions**: Specific suggestions for error resolution
 - **Retry Logic**: Automatic retry for recoverable errors
 
 ## Database Schema Integration
 
 ### New Fields Supported:
 - `session_context`: JSONB field for tracking conversation context
 - `session_id`: Unique identifier for each chat session
 - `session_type`: Categorizes the type of conversation
 - `portfolio_context`: Enhanced portfolio integration with default enabled state
 
 ### SQL Functions Used:
 - `create_new_chat_session()`: Creates conversations with proper defaults
 - `update_session_context()`: Updates session context efficiently
 
 ## Usage Examples
 
 ### Creating a New Conversation
 ```swift
 let conversation = await chatManager.createConversation(
     title: "Portfolio Analysis",
     contextType: .portfolio,
     sessionType: .analysis,
     includePortfolioContext: true
 )
 ```
 
 ### Sending Messages
 ```swift
 let message = await chatManager.sendMessage(
     content: "Analyze my portfolio performance",
     metadata: MessageMetadata(messageType: "analysis_request")
 )
 ```
 
 ### File Upload
 ```swift
 chatManager.uploadAttachment(
     messageId: message.id,
     fileName: "portfolio.csv",
     fileType: "text/csv",
     fileData: csvData
 )
 ```
 
 ### Session Context Updates
 ```swift
 let newContext = SessionContext(
     currentTopic: "Risk Analysis",
     userIntent: "understand_risk",
     conversationFlow: ["greeting", "portfolio_upload", "risk_analysis"]
 )
 chatManager.updateSessionContext(newContext)
 ```
 
 ## Error Handling
 
 ### Automatic Error Management
 The ChatManager automatically handles errors and provides user-friendly feedback:
 
 ```swift
 // Errors are automatically caught and displayed
 @Published var errorMessage: String?
 @Published var showError: Bool = false
 ```
 
 ### Custom Error Handling
 ```swift
 let errorDetails = ChatErrorHandler.handleError(error)
 // Provides user message, suggestions, and retry options
 ```
 
 ## Performance Considerations
 
 ### Pagination
 - Conversations and messages are paginated for optimal performance
 - Configurable page sizes based on device capabilities
 
 ### Caching
 - Local caching of recent conversations and messages
 - Intelligent prefetching of frequently accessed data
 
 ### File Optimization
 - File size validation before upload
 - Automatic compression for supported file types
 - Lazy loading of attachments
 
 ## Future Enhancements
 
 ### Planned Features:
 1. **Real-time collaboration**: Multiple users in shared conversations
 2. **Voice messages**: Audio recording and transcription
 3. **Message reactions**: Emoji reactions and feedback
 4. **Thread replies**: Nested conversation threads
 5. **Export functionality**: Export conversations to various formats
 6. **Advanced search**: Semantic search and filtering options
 7. **AI model selection**: Choose different AI models per conversation
 8. **Conversation templates**: Pre-defined conversation starters
 
 ### Integration Points:
 - **Portfolio Module**: Deep integration with portfolio analysis
 - **Settings Module**: User preferences and chat configuration
 - **Auth Module**: User authentication and session management
 - **Storage Module**: File management and cloud storage
 
 ## Notes for Developers
 
 ### Threading
 - All UI updates are performed on the main thread using `@MainActor`
 - Background tasks use proper async/await patterns
 
 ### State Management
 - Uses SwiftUI's `@Published` for reactive UI updates
 - Maintains consistent state across the application
 
 ### Testing
 - Models include preview data for SwiftUI previews
 - Repository methods are designed for easy unit testing
 - Error handling includes comprehensive test scenarios
 
 ### Dependencies
 - **Supabase**: Database and storage backend
 - **Foundation**: Core Swift functionality
 - **SwiftUI**: UI framework integration
 
 This module provides a solid foundation for a modern chat experience with portfolio integration,
 file sharing, and intelligent session management.
 */

// MARK: - Module Export

// This file serves as documentation and doesn't contain executable code.
// The actual implementation is distributed across the model, repository, manager, and utility files.
