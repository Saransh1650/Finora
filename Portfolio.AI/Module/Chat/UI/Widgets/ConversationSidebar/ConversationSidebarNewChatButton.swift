//
//  ChatSidebarNewChatButton.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 21/9/25.
//

import SwiftUI

struct ConversationSidebarNewChatButton: View {
    @EnvironmentObject var chatManager: ChatManager
    var body: some View {
        Button {
            chatManager.currentConversation = nil
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("New Chat")
                Spacer()
            }
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.selected.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .disabled(chatManager.isCreatingConversation)
    }
}
