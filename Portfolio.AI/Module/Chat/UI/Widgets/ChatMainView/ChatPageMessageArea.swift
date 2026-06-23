//
//  ChatPageMessageArea.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 22/9/25.
//

import SwiftUI

struct ChatPageMessageArea: View {
    @EnvironmentObject var chatManager: ChatManager
    @FocusState var isInputFocused: Bool

    /// Total streamed characters — drives auto-scroll while text grows.
    private var streamingCharCount: Int {
        chatManager.streamingBubbles.reduce(0) { $0 + $1.count }
    }

    var body: some View {
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
                    if chatManager.isLoadingMessages
                        && !chatManager.messages.isEmpty
                    {
                        ProgressView()
                            .frame(height: 50)
                    }

                    // Messages
                    ForEach(chatManager.messages, id: \.id) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }

                    // Live streaming bubbles (one per part, grows as it streams)
                    ForEach(
                        Array(chatManager.streamingBubbles.enumerated()),
                        id: \.offset
                    ) { index, text in
                        if !text.isEmpty {
                            MessageBubbleView(
                                message: ChatMessage(
                                    conversationId: chatManager
                                        .currentConversation?.id ?? UUID(),
                                    userId: "",
                                    role: .assistant,
                                    content: text,
                                    metadata: nil
                                )
                            )
                            .id("streaming-\(index)")
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(
                                        with: .move(edge: .bottom)
                                    ),
                                    removal: .opacity
                                )
                            )
                        }
                    }

                    // Typing indicator — only before the first chunk arrives
                    if chatManager.isSendingMessage
                        && chatManager.streamingBubbles.isEmpty
                    {
                        TypingIndicatorView()
                    }

                    // Bottom spacer
                    Color.clear.frame(height: 20)
                        .id("bottom-anchor")
                }
                .padding(.horizontal, 20)
            }
            .onTapGesture {
                isInputFocused = false
            }
            .onChange(of: chatManager.messages.count) { _, _ in
                // Auto-scroll to bottom when new message arrives
                if let lastMessage = chatManager.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: streamingCharCount) { _, _ in
                // Follow the growing text. Linear + short keeps the scroll
                // gliding smoothly instead of stuttering on each reveal tick.
                withAnimation(.linear(duration: 0.1)) {
                    proxy.scrollTo("bottom-anchor", anchor: .bottom)
                }
            }
        }
        .onTapGesture {
            isInputFocused = false
        }
    }
}

#Preview {
    ChatPageMessageArea()
        .environmentObject(ChatManager())
}
