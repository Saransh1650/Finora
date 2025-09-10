//
//  HomePage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct HomePage: View {
    @State private var isDrawerOpen = false
    @State private var portfolioAnalysis: PortfolioAnalysisModel?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @EnvironmentObject var portfolioManager: PortfolioManager
    
    var body: some View {
        ZStack {
            // Main Content
            VStack(spacing: 0) {
                if let analysis = portfolioAnalysis {
                    // Show AI Dashboard when analysis is available
                    AIDashboardView(analysis: analysis)
                } else {
                    // Show default content when no analysis
                    ScrollView {
                        VStack(spacing: 20) {
                            if isLoading {
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
                                        await analyzePortfolio()
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
                                    .background(AppColors.selected)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .disabled(isLoading)
                                
                                if let errorMessage = errorMessage {
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
        .navigationTitle(portfolioAnalysis != nil ? "" : "Welcome")
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
            
            if portfolioAnalysis != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            portfolioAnalysis = nil
                            errorMessage = nil
                        }
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .foregroundStyle(AppColors.selected)
                            .font(.system(size: 24))
                    }
                }
            }
        }
    }
    
    private func analyzePortfolio() async {
        isLoading = true
        errorMessage = nil
        
        // Convert portfolio stocks to a JSON string for analysis
        do {
            let portfolioData = try JSONEncoder().encode(portfolioManager.stocks)
            let portfolioJsonString = String(data: portfolioData, encoding: .utf8) ?? "No portfolio data"
            
            await GeminiRepo.analyzePortfolio(portfolioData: portfolioJsonString) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    switch result {
                        case .success(let analysis):
                            print("AI Analysis Result: \(analysis)")
                            portfolioAnalysis = analysis
                        case .failure(let error):
                            print("Portfolio Analysis Error: \(error.localizedDescription)")
                            errorMessage = "Failed to analyze portfolio. Please try again."
                    }
                }
            }
        } catch {
            isLoading = false
            errorMessage = "Error encoding portfolio data: \(error.localizedDescription)"
            print("Error encoding portfolio data: \(error)")
        }
    }
}

#Preview {
    HomePage()
}
