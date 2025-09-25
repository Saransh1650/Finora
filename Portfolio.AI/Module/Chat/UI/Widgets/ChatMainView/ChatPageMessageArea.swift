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
                    
                    // Typing indicator
                    if chatManager.isSendingMessage {
                        TypingIndicatorView()
                    }
                    
                    // Bottom spacer
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
            .onTapGesture {
                isInputFocused = false
            }
            .onChange(
                of: chatManager.messages.count,
                perform: { _ in
                    // Auto-scroll to bottom when new message arrives
                    if let lastMessage = chatManager.messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            )
        }
    }
}

#Preview {
    ChatPageMessageArea()
        .environmentObject(ChatManager())
}
