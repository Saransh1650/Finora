//
//  AccountSection.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 17/9/25.
//

import SwiftUI

struct AccountSectionCard: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var portfolioAnalysisManager: PortfolioAnalysisManager

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
                    if isDeleting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                },
                action: {
                    showDeleteConfirmation = true
                }
            )
        }
        .settingsCardStyle()
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await deleteAccount()
                }
            }
        } message: {
            Text(
                "Are you sure you want to permanently delete your account? This action cannot be undone. All your portfolio data and settings will be lost."
            )
        }
    }

    private func deleteAccount() async {
        isDeleting = true

        _ = await portfolioManager.deleteAllStocks()
        _ = await portfolioAnalysisManager.deleteAllAnalyses()
        _ = await chatManager.deleteChat()
        _ = await authManager.signOut()
        
        isDeleting = false
    }
}

#Preview {
    AccountSectionCard()
        .environmentObject(AuthManager())
}
