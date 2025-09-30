//
//  ConversationSidebar.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 21/9/25.
//

import SwiftUI

struct ConversationSidebarView: View {
    @ObservedObject var chatManager: ChatManager
    @Binding var isPresented: Bool
    @State private var searchText = ""

    var filteredConversations: [ConversationSummary] {
        if searchText.isEmpty {
            return chatManager.conversations
        } else {
            return chatManager.conversations.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            ConversationSidebarHeader(isPresented: $isPresented)

//            ConversationSidebarSearchbar(searchText: $searchText)

            ConversationSidebarNewChatButton()

            ConversationList(filteredConversations: filteredConversations)
        }
        .background(AppColors.background)
    }

}
