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
            VStack(spacing: 0) {
                if let analysis = portfolioAnalysisManager.currentAnalysis ?? portfolioAnalysisManager.analysisHistory.first {
                    AIDashboardView(analysis: analysis)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            if portfolioAnalysisManager.isLoading {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text("Analyzing your portfolio...")
                                        .font(.headline)
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                                .padding(40)
                            } else {
                                Button {
                                    Task {
                                        await portfolioAnalysisManager
                                            .generateSummaryAndSave(
                                                stocks: portfolioManager.stocks,
                                            )
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "brain.head.profile")
                                            .font(.title2)
                                        Text("Analyze Portfolio with AI")
                                            .font(.headline)
                                    }
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(AppColors.foreground)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )
                                }
                                .disabled(portfolioAnalysisManager.isLoading)
                                
                                if let errorMessage = portfolioAnalysisManager
                                    .errorMessage
                                {
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.top)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(AppColors.pureBackground)
                    Spacer()
                    Spacer()
                }
            }
            
            // Sidebar with overlay
            if isDrawerOpen {
                
                // Background overlay
                AppColors.textPrimary.opacity(0.4)
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
        .background(AppColors.pureBackground)
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.large)
        .toolbarVisibility(
            isDrawerOpen ? .hidden : .visible,
            for: .navigationBar
        )
        .toolbar {
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

#Preview {
    HomePage()
}
