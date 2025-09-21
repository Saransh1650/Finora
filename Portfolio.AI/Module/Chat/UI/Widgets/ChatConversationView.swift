//
//  ChatConversationView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import SwiftUI

struct ChatConversationView: View {
    let conversation: ChatConversation
    @EnvironmentObject var chatManager: ChatManager
    
    @State private var message = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Messages area
            messagesArea
            
            // Input area
            inputArea
        }
        .background(AppColors.pureBackground)
        .onAppear {
            chatManager.loadMessages(refresh: true)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text("\(chatManager.messages.count) messages")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Options menu
            Menu {
                Button("Rename Conversation") {
                    // TODO: Implement rename functionality
                }
                
                Button("Export Chat") {
                    // TODO: Implement export functionality
                }
                
                Divider()
                
                Button("Delete Conversation", role: .destructive) {
                    chatManager.deleteConversation(conversation.id)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(AppColors.foreground)
                    )
            }
            .menuStyle(BorderlessButtonMenuStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppColors.pureBackground)
        .overlay(
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Load more messages trigger
                    if chatManager.messages.count > 0 {
                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                chatManager.loadMoreMessages()
                            }
                    }
                    
                    // Loading indicator for more messages
                    if chatManager.isLoadingMessages && !chatManager.messages.isEmpty {
                        ProgressView()
                            .frame(height: 50)
                    }
                    
                    // Messages
                    ForEach(chatManager.messages, id: \.id) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                    
                    // Typing indicator
                    if chatManager.isSendingMessage {
                        TypingIndicatorView()
                    }
                    
                    // Bottom spacer
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
            .onChange(of: chatManager.messages.count) { _ in
                // Auto-scroll to bottom when new message arrives
                if let lastMessage = chatManager.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var inputArea: some View {
        VStack(spacing: 0) {
            // Portfolio context indicator
            if conversation.hasPortfolioData {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.selected)
                    
                    Text("Portfolio context enabled")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            
            // Input field
            HStack(spacing: 12) {
                // Attachment button
                Button {
                    // TODO: Implement file attachment
                } label: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(AppColors.foreground)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Text input
                TextField("Message Portfolio AI...", text: $message, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.foreground)
                    .cornerRadius(20)
                    .lineLimit(1...5)
                    .onSubmit {
                        sendMessage()
                    }
                
                // Send button
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: chatManager.isSendingMessage ? "stop.fill" : "arrow.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(canSend ? AppColors.selected : AppColors.textSecondary)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!canSend && !chatManager.isSendingMessage)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(AppColors.pureBackground)
        .overlay(
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 1),
            alignment: .top
        )
    }
    
    private var canSend: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !chatManager.isSendingMessage
    }
    
    private func sendMessage() {
        guard canSend else { return }
        
        let messageToSend = message.trimmingCharacters(in: .whitespacesAndNewlines)
        message = ""
        
        Task {
            await chatManager.sendMessage(content: messageToSend)
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicatorView: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // AI Avatar
            Image(systemName: "brain.head.profile")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(AppColors.selected)
                )
            
            // Typing dots
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(AppColors.textSecondary)
                        .frame(width: 6, height: 6)
                        .scaleEffect(animationOffset == CGFloat(index) ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.foreground)
            .cornerRadius(16)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .onAppear {
            animationOffset = 0
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
                animationOffset = animationOffset < 2 ? animationOffset + 1 : 0
            }
        }
    }
}

//#Preview {
//    ChatConversationView(
//        conversation: ChatConversation(
//            id: UUID(),
//            userId: "",
//            title: "Portfolio Analysis",
//            contextType: .portfolio,
//            portfolioContext: PortfolioContext(),
//            sessionContext: SessionContext(),
//            sessionType: .chat,
//            isActive: true,
//            
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        chatManager: ChatManager()
//    )
//}
