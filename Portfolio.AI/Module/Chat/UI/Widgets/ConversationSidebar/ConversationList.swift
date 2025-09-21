//
//  ConversationList.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 21/9/25.
//

import SwiftUI

struct ConversationList: View {
    @EnvironmentObject var chatManager: ChatManager
    var filteredConversations: [ConversationSummary]
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(filteredConversations, id: \.id) { conversation in
                    ConversationRowView(
                        conversation: conversation,
                        isSelected: chatManager.currentConversation?.id == conversation.id,
                        onSelect: {
                            chatManager.selectConversation(conversation.id)
                        },
                        onDelete: {
                            chatManager.deleteConversation(conversation.id)
                        }
                    )
                }
                
                if chatManager.isLoadingConversations {
                    ProgressView()
                        .frame(height: 50)
                }
                
                // Load more trigger
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        chatManager.loadMoreConversations()
                    }
            }
            .padding(.horizontal, 8)
        }
    }
}


