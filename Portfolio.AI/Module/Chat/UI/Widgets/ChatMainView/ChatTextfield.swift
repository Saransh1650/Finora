//
//  ChatTextfield.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 22/9/25.
//

import SwiftUI

struct ChatTextfield: View {
    @State private var message: String = ""
    @FocusState var isInputFocused: Bool
    @EnvironmentObject private var chatManager: ChatManager
    @EnvironmentObject private var portfolioManager: PortfolioManager

    var body: some View {
        VStack(spacing: 0) {
            // Input field
            HStack(spacing: 12) {
                // Text input
                TextField(
                    "Message Finora...",
                    text: $message,
                    axis: .vertical
                )
                .focused($isInputFocused)
                .textFieldStyle(.automatic)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppColors.foreground)
                .cornerRadius(20)
                .lineLimit(1...5)
                .onSubmit {
                    Task {
                        await sendMessage()
                    }
                }

                // Send button
                Button {
                    Task {
                        await sendMessage()
                    }
                } label: {
                    if chatManager.isSendingMessage {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .white)
                            )
                            .frame(width: 14, height: 14)
                    } else {
                        Image(systemName: "arrow.up")

                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(
                                        canSend
                                            ? Color.blue
                                            : AppColors.textSecondary
                                    )
                            )
                    }
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
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !chatManager.isSendingMessage
    }

    private func sendMessage() async {
        guard canSend else { return }

        let messageToSend = message.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        message = ""

        Task {
            if chatManager.currentConversation == nil {
                if await chatManager.createConversation(
                    title: messageToSend,
                    includePortfolioContext: true
                )
                    != nil
                {
                    await chatManager.sendMessage(
                        content: messageToSend,
                        portfolioContext: "\(portfolioManager.stocks)"
                    )
                }
            } else {
                await chatManager.sendMessage(
                    content: messageToSend,
                    portfolioContext: "\(portfolioManager.stocks)"
                )
            }
        }
    }
}
