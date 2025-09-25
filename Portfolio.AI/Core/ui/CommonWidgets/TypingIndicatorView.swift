//
//  TypingIndicator.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 22/9/25.
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(AppColors.selected)
                )
            
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(AppColors.textSecondary)
                        .frame(width: 6, height: 6)
                        .scaleEffect(
                            animationOffset == CGFloat(index) ? 1.2 : 1.0
                        )
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.foreground)
            .cornerRadius(16)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .onAppear {
            animationOffset = 0
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
                animationOffset = animationOffset < 2 ? animationOffset + 1 : 0
            }
        }
    }
}

#Preview {
    TypingIndicatorView()
}
