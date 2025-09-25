//
//  AccountSection.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 17/9/25.
//

import SwiftUI

struct AccountSectionCard: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 16) {
            SettingsRow(
                icon: "rectangle.portrait.and.arrow.forward.fill",
                title: "Log Out",
                subtitle: "Lout out of the current account",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    Task {
                        await authManager.signOut()
                    }
                }
            )

            SettingsRow(
                icon: "trash.fill",
                title: "Delete Account",
                subtitle: "This action will permanently delete your account",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {

                }
            )
        }
        .settingsCardStyle()
    }
}

#Preview {
    AccountSectionCard()
        .environmentObject(AuthManager())
}
