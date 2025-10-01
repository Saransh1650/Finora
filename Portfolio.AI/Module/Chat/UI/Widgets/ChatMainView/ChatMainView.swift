//
//  ChatMainView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 21/9/25.
//

import SwiftUI

struct ChatMainView: View {
    @EnvironmentObject var chatManager: ChatManager
    @Binding var isSidebarPresented: Bool

    var body: some View {
        VStack(spacing: 0) {

            // Chat content
            Group {
                if let conversation = chatManager.currentConversation {
                    ChatConversationView(
                        conversation: conversation
                    )
                } else {
                    ChatWelcomeView()
                }
            }
        }
        .background(AppColors.pureBackground)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSidebarPresented.toggle()
                    }
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
    }
}
