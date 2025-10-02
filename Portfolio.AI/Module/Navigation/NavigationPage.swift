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
        VStack(spacing: 0) {

            ZStack {
                switch selectedTab {
                case .home:
                    NavigationView {
                        HomePage()
                            .environmentObject(portfolioManager)
                            .environmentObject(portfolioAnalysisManager)
                            .environmentObject(chatManager)
                    }
                case .portfolio:
                    NavigationView {
                        PortfolioPage()
                            .environmentObject(portfolioManager)
                    }
                case .settings:
                    NavigationView {
                        SettingsPage()
                            .environmentObject(portfolioManager)
                            .environmentObject(portfolioAnalysisManager)
                            .environmentObject(chatManager)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomNavBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            // Check for updates when app launches
            appUpdateManager.checkForUpdatesAutomatically()
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

#Preview {
    NavigationPage()
}
