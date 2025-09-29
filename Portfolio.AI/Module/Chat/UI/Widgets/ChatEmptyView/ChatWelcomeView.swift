//
//  ChatWelcomeView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import SwiftUI

struct ChatWelcomeView: View {
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var message: String = ""
    @FocusState var isInputActive: Bool

    private let suggestedQuestions = [
        "Analyze my current portfolio performance",
        "What are the key risks in my investments?",
        "How can I diversify my portfolio better?",
        "Show me market trends for my holdings",
        "What's my portfolio's expected return?",
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

                    Text(
                        "Get personalized insights about your portfolio and investment strategy"
                    )
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

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ],
                        spacing: 8
                    ) {
                        ForEach(suggestedQuestions, id: \.self) { question in
                            SuggestedQuestionCard(
                                question: question,
                                onTap: {
                                    startConversationWith(
                                        question: question,
                                        portfolioContext:
                                            "\(portfolioManager.stocks)"
                                    )
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
            }

            Spacer()
            ChatTextfield(isInputFocused: _isInputActive)
        }
        .background(AppColors.pureBackground)
        .onTapGesture {
            isInputActive = false
        }
    }

    private func startConversationWith(
        question: String,
        portfolioContext: String
    ) {
        Task {
            if await chatManager.createConversation(
                title: question,
                includePortfolioContext: true
            ) != nil {
                await chatManager.sendMessage(
                    content: question,
                    portfolioContext: portfolioContext
                )
            }
        }
    }
}
#Preview {
    ChatWelcomeView()
        .environmentObject(ChatManager())
        .environmentObject(PortfolioManager())
}
