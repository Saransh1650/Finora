//
//  HomePage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct HomePage: View {
    @State private var isDrawerOpen = false
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
                    // Show analysis prompt when 2+ stocks but no analysis yet
                    ReadyToAnalyzeView()
                }
            }

            // Sidebar with overlay
            if isDrawerOpen && !portfolioAnalysisManager.isLoading {
                // Background overlay
                AppColors.foreground.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isDrawerOpen = false
                        }
                    }
                    .zIndex(1)

                // Drawer content
                HStack {
                    SideAppDrawer(isOpen: $isDrawerOpen)
                    Spacer()
                }
                .transition(.move(edge: .leading))
                .zIndex(2)
            }
        }
        .navigationTitle("Portfolio.AI")
        .navigationBarTitleDisplayMode(.large)
        .toolbarVisibility(
            (isDrawerOpen || portfolioAnalysisManager.isLoading)
                ? .hidden : .visible,
            for: .navigationBar
        )
        .toolbar {
            if !portfolioAnalysisManager.isLoading {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isDrawerOpen.toggle()
                        }
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(AppColors.selected)
                            .font(.system(size: 24))
                    }
                }
            }
        }
    }
}

#Preview {
    HomePage()
        .environmentObject(PortfolioManager())
        .environmentObject(PortfolioAnalysisManager())
}
