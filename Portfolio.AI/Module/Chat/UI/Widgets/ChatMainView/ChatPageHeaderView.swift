//
//  ChatPageHeaderView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 22/9/25.
//

import SwiftUI

struct ChatPageHeaderView: View {
    var title: String
    var messageCount: Int
    var onDelete: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text("\(messageCount) messages")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Options menu
            Menu {
                Button("Rename Conversation") {
                    // TODO: Implement rename functionality
                }
                
                Button("Export Chat") {
                    // TODO: Implement export functionality
                }
                
                Divider()
                
                Button("Delete Conversation", role: .destructive) {
                    onDelete()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(AppColors.foreground)
                    )
            }
            .menuStyle(BorderlessButtonMenuStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppColors.pureBackground)
        .overlay(
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    ChatPageHeaderView(title: "", messageCount: 2, onDelete: {})
}
