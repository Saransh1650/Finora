//
//  ShareInformationCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 16/9/25.
//

import SwiftUI

struct ShareInformationCard: View {
    @Binding var showingShareSheet: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            SettingsRow(
                icon: "square.and.arrow.up.fill",
                title: "Share App",
                subtitle: "Tell friends about Portfolio.AI",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    showingShareSheet = true
                }
            )
            
            SettingsRow(
                icon: "doc.text.fill",
                title: "Privacy Policy",
                subtitle: "How we protect your data",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    // Open privacy policy
                }
            )
            
            SettingsRow(
                icon: "doc.fill",
                title: "Terms of Service",
                subtitle: "App usage terms and conditions",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    // Open terms of service
                }
            )
        }
        .settingsCardStyle()
    }
}


