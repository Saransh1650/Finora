//
//  ChatPage.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import SwiftUI

struct ChatPage: View {
    @EnvironmentObject private var chatManager : ChatManager
    @State private var isSidebarPresented = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Main chat view
            ChatMainView(
                isSidebarPresented: $isSidebarPresented
            )
            
            // Background overlay (when sidebar is shown)
            if isSidebarPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSidebarPresented = false
                        }
                    }
            }
            
            // Sidebar
            if isSidebarPresented {
                ConversationSidebarView(
                    chatManager: chatManager,
                    isPresented: $isSidebarPresented
                )
                .frame(width: 320)
                .background(AppColors.background)
                .shadow(radius: 10)
                .transition(.move(edge: .leading))
            }
        }
        .onAppear {
            chatManager.loadConversations()
        }
    }
}


#Preview {
    ChatPage()
        .environmentObject(ChatManager())
}
