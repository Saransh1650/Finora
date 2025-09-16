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
                    ?? portfolioAnalysisManager.analysisHistory.first
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
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    HomePage()
        .environmentObject(PortfolioManager())
        .environmentObject(PortfolioAnalysisManager())
}
