//
//  SettingsPage.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/9/25.
//

import SwiftUI

struct SettingsPage: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var showingShareSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SettingsHeader()

                SettingsSection(title: "Appearance", icon: "paintbrush.fill") {
                    ThemeSettingsCard(settingsManager: settingsManager)
                }

                SettingsSection(title: "Subscription", icon: "crown.fill") {
                    SubscriptionCard()
                }

                SettingsSection(
                    title: "Support & Feedback",
                    icon: "questionmark.circle.fill"
                ) {
                    SupportFeedbackCard()
                }

                SettingsSection(title: "About", icon: "info.circle.fill") {
                    ShareInformationCard(showingShareSheet: $showingShareSheet)
                }

                AppVersionFooter()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(AppColors.pureBackground)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [
                "Check out Portfolio.AI - The smartest way to manage your investments!",
                URL(string: "https://portfolio-ai.app")!,
            ])
        }
    }
}

#Preview {
    NavigationView {
        SettingsPage()
    }
}
