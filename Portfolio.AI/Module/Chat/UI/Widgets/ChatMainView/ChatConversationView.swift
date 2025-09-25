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
    @EnvironmentObject var portfolioManager: PortfolioManager
    @FocusState private var isInputFocused: Bool

    @State private var message = ""

    var body: some View {
        VStack(spacing: 0) {

            ChatPageHeaderView(
                title: conversation.title,
                messageCount: chatManager.messages.count
            ) {
                chatManager.deleteConversation(conversation.id)
            }

            ChatPageMessageArea()

            ChatTextfield(message: $message)
        }
        .background(AppColors.pureBackground)
        .onAppear {
            chatManager.loadMessages(refresh: true)
        }
    }

}

#Preview {
    ChatConversationView(
        conversation: ChatConversation(
            id: UUID(),
            userId: "",
            title: "My Portfolio Chat",
            createdAt: Date()
        )
    )
    .environmentObject(ChatManager())
    .environmentObject(PortfolioManager())
}
