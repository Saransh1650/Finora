//
//  SwiftUIView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 24/9/25.
//

import SwiftUI

struct SuggestedQuestionCard: View {
    let question: String
    let onTap: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(question)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isHovering
                            ? AppColors.foreground.opacity(0.8)
                            : AppColors.foreground
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    SuggestedQuestionCard(question: "") {

    }
}
