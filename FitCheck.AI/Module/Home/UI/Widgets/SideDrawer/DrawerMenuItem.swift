//
//  DrawerMenuItem.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct DrawerMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
            )
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Rectangle()
                .fill(AppColors.pureBackground)
        )
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    DrawerMenuItem(
        icon: "house.fill",
        title: "Home",
        action: { print("Home tapped") }
    )
}
