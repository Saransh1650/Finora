//
//  ConversationRowContent.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 20/9/25.
//

import SwiftUI

struct ConversationRowContent: View {
    var isSelected: Bool
    var isHovering: Bool
    var conversation: ConversationSummary
    @Binding var showingDeleteAlert: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Chat icon
            Image(systemName: "message.fill")
                .font(.system(size: 16))
                .foregroundColor(
                    isSelected ? AppColors.selected : AppColors.textSecondary
                )
                .frame(width: 20)

            Text(conversation.title)

            Spacer()

            Button {
                showingDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            .buttonStyle(PlainButtonStyle())

        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    isSelected ? AppColors.selected.opacity(0.15) : Color.clear
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected ? AppColors.selected.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    ConversationRowView(
        conversation: ConversationSummary(
            id: UUID(),
            userId: "",
            title: "Asd",
            contextType: .general,
            sessionContext: SessionContext(),
            sessionId: "",
            sessionType: .analysis,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date(),
            messageCount: 2
        ),
        isSelected: true
    ) {

    } onDelete: {

    }

}
