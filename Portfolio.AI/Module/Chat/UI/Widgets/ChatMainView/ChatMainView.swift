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
        .navigationTitle("FinAI")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSidebarPresented = true
                    }
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(12)
                        .background(AppColors.background)
                        .clipShape(Circle())
                }
            }
        }
    }
}
