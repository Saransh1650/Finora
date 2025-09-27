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
            // Background gradient
            LinearGradient(
                colors: [AppColors.pureBackground, AppColors.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
                        }
                    }
                } else {
                    ReadyToAnalyzeView()
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            // Chat FAB
            Button {
                showChat = true
            } label: {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
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
