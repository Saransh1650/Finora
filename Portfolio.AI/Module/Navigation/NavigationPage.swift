//
//  MainTabView.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import SwiftUI

struct NavigationPage: View {
    @State private var selectedTab: TabItem = .home
    @StateObject var portfolioManager = PortfolioManager()
    @StateObject var portfolioAnalysisManager = PortfolioAnalysisManager()
    @StateObject var chatManager = ChatManager()
    @StateObject var appUpdateManager = AppUpdateManager()

    var body: some View {
        TabView(selection: $selectedTab) {
            HomePage()
                .environmentObject(portfolioManager)
                .environmentObject(portfolioAnalysisManager)
                .environmentObject(chatManager)
                .tabItem {
                    Label(TabItem.home.title, systemImage: TabItem.home.icon)
                }
                .tag(TabItem.home)

            PortfolioPage()
                .environmentObject(portfolioManager)
                .tabItem {
                    Label(
                        TabItem.portfolio.title,
                        systemImage: TabItem.portfolio.icon
                    )
                }
                .tag(TabItem.portfolio)

            SettingsPage()
                .environmentObject(portfolioManager)
                .environmentObject(portfolioAnalysisManager)
                .environmentObject(chatManager)
                .tabItem {
                    Label(
                        TabItem.settings.title,
                        systemImage: TabItem.settings.icon
                    )
                }
                .tag(TabItem.settings)
        }
        .tint(AppColors.selected)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            appUpdateManager.checkForUpdatesAutomatically()
        }
        .overlay {
            if appUpdateManager.showUpdateDialog,
                let updateResult = appUpdateManager.updateResult
            {
                ForceUpdateDialog(
                    updateResult: updateResult,
                    onUpdatePressed: {
                        appUpdateManager.handleUpdatePressed()
                    },
                    onLaterPressed: updateResult.isForceUpdate
                        ? nil
                        : {
                            appUpdateManager.handleLaterPressed()
                        }
                )
                .transition(.opacity.combined(with: .scale))
                .animation(
                    .easeInOut(duration: 0.3),
                    value: appUpdateManager.showUpdateDialog
                )
            }
        }
    }
}

#Preview {
    NavigationPage()
}
