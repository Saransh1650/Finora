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
    
    private var conversationDetails : some View{
        VStack(alignment: .leading, spacing: 4) {
            // Title
            Text(conversation.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(
                    isSelected ? AppColors.selected : AppColors.textPrimary
                )
                .lineLimit(1)
                .truncationMode(.tail)
            
            // Last message preview
            if !conversation.lastMessagePreview.isEmpty
            {
                Text(conversation.lastMessagePreview)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            // Time ago
            Text(TimeAgoString.timeAgoString(from: conversation.updatedAt))
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
        }

    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Chat icon
            Image(systemName: "message.fill")
                .font(.system(size: 16))
                .foregroundColor(
                    isSelected ? AppColors.selected : AppColors.textSecondary
                )
                .frame(width: 20)

          
            Spacer()

            // Delete button (shown on hover)
            if isHovering {
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
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

//#Preview {
//    ConversationRowContent(
//        isSelected: true,
//        isHovering: true,
//        conversation: ConversationSummary(),
//        showingDeleteAlert:
//    )
//
//}
