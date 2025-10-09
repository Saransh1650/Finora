//
//  SettingsPage.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/9/25.
//

import SwiftUI

struct SettingsPage: View {
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var appUpdateManager = AppUpdateManager()
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    SettingsHeader()

                    SettingsSection(
                        title: "Personalization",
                        icon: "person.fill"
                    ) {
                        ThemeSettingsCard()
                    }

                    //                    SettingsSection(title: "Subscription", icon: "crown.fill") {
                    //                        SubscriptionCard()
                    //                    }

                    SettingsSection(
                        title: "Support & Feedback",
                        icon: "questionmark.circle.fill"
                    ) {
                        SupportFeedbackCard()
                    }

                    SettingsSection(title: "About", icon: "info.circle.fill") {
                        ShareInformationCard(
                            showingShareSheet: $showingShareSheet
                        )
                    }

                    SettingsSection(
                        title: "App Updates",
                        icon: "arrow.down.circle.fill"
                    ) {
                        AppUpdateCard(appUpdateManager: appUpdateManager)
                    }

                    SettingsSection(
                        title: "Account",
                        icon: "person.crop.circle.fill"
                    ) {
                        AccountSectionCard()
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
                    "Check out Finora - The Smarter way to manage your Portfolio!",
                    URL(string: AppConstants.appUrl)!,
                ])
            }
            .overlay {
                // Show update dialog when needed
                if appUpdateManager.showUpdateDialog,
                   let updateResult = appUpdateManager.updateResult {
                    ForceUpdateDialog(
                        updateResult: updateResult,
                        onUpdatePressed: {
                            appUpdateManager.handleUpdatePressed()
                        },
                        onLaterPressed: updateResult.isForceUpdate ? nil : {
                            appUpdateManager.handleLaterPressed()
                        }
                    )
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.3), value: appUpdateManager.showUpdateDialog)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SettingsPage()
    }
}
