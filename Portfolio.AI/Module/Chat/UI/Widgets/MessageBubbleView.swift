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
        isUser ? AppColors.selected : AppColors.foreground
    }
    
    private var textColor: Color {
        isUser ? .white : AppColors.textPrimary
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !isUser {
                // AI Avatar
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(AppColors.selected)
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
                .cornerRadius(16, corners: isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                .frame(maxWidth: 600, alignment: isUser ? .trailing : .leading)
                
                // Message actions
                messageActionsView
                
                // Timestamp
                timestampView
            }
            
            if isUser {
                // User Avatar
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer(minLength: 60)
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
    
    private var messageActionsView: some View {
        HStack(spacing: 8) {
            // Copy button
            Button {
                copyMessage()
            } label: {
                Image(systemName: showingCopyConfirmation ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Share button (for user messages)
            if isUser {
                Button {
                    shareMessage()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Regenerate button (for AI messages)
            if !isUser {
                Button {
                    regenerateResponse()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .opacity(0.7)
    }
    
    private var timestampView: some View {
        Text(FormatDateTime.formatTimestamp(message.createdAt))
            .font(.system(size: 11))
            .foregroundColor(AppColors.textSecondary)
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

// MARK: - Custom Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
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
                content: "Can you analyze my portfolio performance over the last quarter?",
                metadata: nil
            )
        )
        
        // AI response
        MessageBubbleView(
            message: ChatMessage(
                conversationId: UUID(),
                userId: "user123",
                role: .assistant,
                content: "Based on your portfolio data, here's a comprehensive analysis of your performance over the last quarter:\n\n• Overall return: +8.2%\n• Best performing asset: AAPL (+15.3%)\n• Underperforming asset: TSLA (-5.1%)\n• Risk-adjusted return (Sharpe ratio): 1.42\n\nYour portfolio has outperformed the market benchmark by 2.1%. The technology sector allocation has been particularly beneficial during this period.",
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
