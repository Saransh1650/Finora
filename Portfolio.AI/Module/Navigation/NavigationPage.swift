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
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomNavBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    NavigationPage()
}
