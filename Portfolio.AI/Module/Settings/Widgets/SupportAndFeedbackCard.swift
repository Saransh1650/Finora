//
//  SupportAndFeedbackCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 16/9/25.
//

import SwiftUI

struct SupportFeedbackCard: View {
    var body: some View {
        VStack(spacing: 16) {
            SettingsRow(
                icon: "questionmark.circle.fill",
                title: "Help Center",
                subtitle: "Get help and find answers",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    // Open help center
                }
            )
            
            SettingsRow(
                icon: "envelope.fill",
                title: "Contact Support",
                subtitle: "Get personalized help",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    // Open email composer
                }
            )
            
            SettingsRow(
                icon: "heart.fill",
                title: "Send Feedback",
                subtitle: "Help us improve the app",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    // Open feedback form
                }
            )
            
            SettingsRow(
                icon: "star.fill",
                title: "Rate Portfolio.AI",
                subtitle: "Leave a review on the App Store",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    // Open App Store review
                }
            )
        }
        .settingsCardStyle()
    }
}


