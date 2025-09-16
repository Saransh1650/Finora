//
//  SubscriptionCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 16/9/25.
//

import SwiftUI

struct SubscriptionCard: View {
    var body: some View {
        VStack(spacing: 16) {
            SettingsRow(
                icon: "crown.fill",
                title: "Portfolio.AI Pro",
                subtitle: "Unlock premium AI insights",
                trailing: {
                    StatusBadge(text: "Pro", status: .success)
                },
                action: {
                    // Handle subscription management
                }
            )
            
            SettingsRow(
                icon: "creditcard.fill",
                title: "Manage Subscription",
                subtitle: "View billing and payment options",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    // Handle subscription management
                }
            )
            
            SettingsRow(
                icon: "gift.fill",
                title: "Restore Purchases",
                subtitle: "Restore previous purchases",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    // Handle restore purchases
                }
            )
        }
        .settingsCardStyle()
    }
}

