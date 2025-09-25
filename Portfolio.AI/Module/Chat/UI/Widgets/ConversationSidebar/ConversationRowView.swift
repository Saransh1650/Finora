//
//  ConversationRowView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import SwiftUI

struct ConversationRowView: View {
    let conversation: ConversationSummary
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    @State private var showingDeleteAlert = false
    @State private var isHovering = false

    var body: some View {
        Button(action: onSelect) {
            ConversationRowContent(
                isSelected: isSelected,
                isHovering: isHovering,
                conversation: conversation,
                showingDeleteAlert: $showingDeleteAlert
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovering = hovering
        }
        .alert("Delete Conversation", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text(
                "Are you sure you want to delete this conversation? This action cannot be undone."
            )
        }
    }
}

//#Preview {
//    VStack {
//        ConversationRowView(
//            conversation: ConversationSummary(
//                from: , id: UUID(),
//                userId: "",
//                title: "Portfolio Analysis Discussion",
//                lastMessage: "What are the key insights from my portfolio?",
//                messageCount: 5,
//                createdAt: Date().addingTimeInterval(-3600),
//                updatedAt: Date().addingTimeInterval(-300)
//            ),
//            isSelected: false,
//            onSelect: { },
//            onDelete: { }
//        )
//
//        ConversationRowView(
//            conversation: ConversationSummary(
//                id: UUID(),
//                userId: "",
//                title: "Investment Strategy",
//                lastMessage: "Based on your risk profile, I recommend...",
//                messageCount: 12,
//                createdAt: Date().addingTimeInterval(-7200),
//                updatedAt: Date().addingTimeInterval(-600)
//            ),
//            isSelected: true,
//            onSelect: { },
//            onDelete: { }
//        )
//    }
//    .padding()
//    .background(AppColors.background)
//}
