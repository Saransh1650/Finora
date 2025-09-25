//
//  MessageBubbleView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    @State private var showingCopyConfirmation = false
    private var isUser: Bool {
        message.role == .user
    }
    private var bubbleColor: Color {
        isUser ? AppColors.selected : AppColors.background
    }
    private var textColor: Color {
        isUser ? AppColors.pureBackground : AppColors.textPrimary
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !isUser {
                // AI Avatar
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.pureBackground)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(AppColors.textSecondary)
                    )
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
                // Message bubble
                VStack(alignment: .leading, spacing: 8) {
                    // Message content
                    Text(message.content)
                        .font(.system(size: 14))
                        .foregroundColor(textColor)
                        .textSelection(.enabled)
                        .multilineTextAlignment(.leading)

                    // Message metadata (tokens, processing time, etc.)
                    if !isUser && shouldShowMetadata {
                        messageMetadataView
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(bubbleColor)
                .cornerRadius(
                    16,
                    corners: isUser
                        ? [.topLeft, .topRight, .bottomLeft]
                        : [.topLeft, .topRight, .bottomRight]
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: isUser ? .trailing : .leading
                )

                // Timestamp
                Text(FormatDateTime.formatTimestamp(message.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }

            if isUser {
                // User Avatar
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.textSecondary)
            }

            if !isUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }

    private var shouldShowMetadata: Bool {
        message.tokensUsed > 0 || message.processingTimeMs > 0
    }

    private var messageMetadataView: some View {
        HStack(spacing: 12) {
            if message.tokensUsed > 0 {
                Label("\(message.tokensUsed)", systemImage: "text.alignleft")
                    .font(.system(size: 11))
                    .foregroundColor(textColor.opacity(0.7))
            }

            if message.processingTimeMs > 0 {
                Label("\(message.processingTimeMs)ms", systemImage: "clock")
                    .font(.system(size: 11))
                    .foregroundColor(textColor.opacity(0.7))
            }
        }
    }

    private func copyMessage() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showingCopyConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showingCopyConfirmation = false
            }
        }
    }

    private func shareMessage() {
        // TODO: Implement share functionality
        print("Share message: \(message.content)")
    }

    private func regenerateResponse() {
        // TODO: Implement regenerate functionality
        print("Regenerate response for message: \(message.id)")
    }

}

#Preview {
    VStack(spacing: 16) {
        // User message
        MessageBubbleView(
            message: ChatMessage(
                conversationId: UUID(),
                userId: "user123",
                role: .user,
                content:
                    "Can you analyze my portfolio performance over the last quarter?",
                metadata: nil
            )
        )

        // AI response
        MessageBubbleView(
            message: ChatMessage(
                conversationId: UUID(),
                userId: "user123",
                role: .assistant,
                content:
                    "Based on your portfolio data, here's a comprehensive analysis of your performance over the last quarter:\n\n• Overall return: +8.2%\n• Best performing asset: AAPL (+15.3%)\n• Underperforming asset: TSLA (-5.1%)\n• Risk-adjusted return (Sharpe ratio): 1.42\n\nYour portfolio has outperformed the market benchmark by 2.1%. The technology sector allocation has been particularly beneficial during this period.",
                metadata: MessageMetadata(
                    temperature: 0.7,
                    maxTokens: 2048
                ),
                tokensUsed: 156,
                processingTimeMs: 1250
            )
        )
    }
    .padding()
    .background(AppColors.pureBackground)
}
