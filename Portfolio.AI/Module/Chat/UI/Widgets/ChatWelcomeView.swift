//
//  ChatWelcomeView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import SwiftUI

struct ChatWelcomeView: View {
    @EnvironmentObject var chatManager: ChatManager
    
    private let suggestedQuestions = [
        "Analyze my current portfolio performance",
        "What are the key risks in my investments?",
        "How can I diversify my portfolio better?",
        "Show me market trends for my holdings",
        "What's my portfolio's expected return?"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Welcome content
            Spacer()
            
            VStack(spacing: 24) {
                // AI Icon
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.selected)
                
                // Welcome text
                VStack(spacing: 8) {
                    Text("Portfolio AI Assistant")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Get personalized insights about your portfolio and investment strategy")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Suggested questions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Try asking:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(suggestedQuestions, id: \.self) { question in
                            SuggestedQuestionCard(
                                question: question,
                                onTap: {
                                    startConversationWith(question: question)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Input area
            ChatInputView(
                placeholder: "Ask me anything about your portfolio...",
                onSend: { message in
                    startConversationWith(question: message)
                }
            )
        }
        .background(AppColors.pureBackground)
    }
    
    private func startConversationWith(question: String) {
        Task {
            if let conversation = await chatManager.createConversation(
                title: question,
                includePortfolioContext: true
            ) {
                await chatManager.sendMessage(content: question)
            }
        }
    }
}

// MARK: - Suggested Question Card
struct SuggestedQuestionCard: View {
    let question: String
    let onTap: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(question)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovering ? AppColors.foreground.opacity(0.8) : AppColors.foreground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Chat Input View
struct ChatInputView: View {
    let placeholder: String
    let onSend: (String) -> Void
    
    @State private var message = ""
    @State private var isHovering = false
    
    private var canSend: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Text input
            TextField(placeholder, text: $message, axis: .vertical)
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
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(canSend ? AppColors.selected : AppColors.textSecondary)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canSend)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppColors.pureBackground)
        .overlay(
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 1),
            alignment: .top
        )
    }
    
    private func sendMessage() {
        guard canSend else { return }
        
        let messageToSend = message.trimmingCharacters(in: .whitespacesAndNewlines)
        message = ""
        onSend(messageToSend)
    }
}

#Preview {
    ChatWelcomeView()
        .environmentObject(ChatManager())
}
