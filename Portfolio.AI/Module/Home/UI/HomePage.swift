//
//  HomePage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct HomePage: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var portfolioAnalysisManager: PortfolioAnalysisManager
    @EnvironmentObject var chatManager: ChatManager
    @State private var showChat = false

    var body: some View {
        ZStack {
            AppColors.pureBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if portfolioAnalysisManager.fetchLoading {
                    PortfolioLoadingAnimation(showText: true)
                } else if portfolioManager.stocks.count < 2 {
                    // Show message when less than 2 stocks
                    MinimumStocksRequiredView()
                } else if let analysis = portfolioAnalysisManager
                    .currentAnalysis
                {
                    VStack(spacing: 0) {
                        ScrollView {
                            HeaderWithAnalysisButton()
                            AIDashboardView(analysis: analysis)
                            Text("Have More Doubts ? Ask Finora AI")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.top, 10)
                                .padding(.bottom, 20)
                        }
                    }
                } else {
                    ReadyToAnalyzeView()
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            // Animated Chat FAB
            AnimatedChatFAB {
                showChat = true
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showChat) {
            NavigationStack {
                ChatPage()
                    .environmentObject(chatManager)
                    .environmentObject(portfolioManager)
            }
        }
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    HomePage()
        .environmentObject(PortfolioManager())
        .environmentObject(PortfolioAnalysisManager())
        .environmentObject(ChatManager())
}
