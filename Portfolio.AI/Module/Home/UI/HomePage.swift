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
    
    var body: some View {
        ZStack {
            // Main Content
            VStack(spacing: 0) {
                ScrollView {
                    Button {
                        Task {
                            await analyzePortfolio()
                        }
                    } label: {
                        Text("Analyze Portfolio with AI")
                    }
                }
                .background(AppColors.pureBackground)
                Spacer()
                Spacer()
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
    
    private func analyzePortfolio() async {

        
        // Convert portfolio stocks to a JSON string for analysis
        do {
            let portfolioData = try JSONEncoder().encode(portfolioManager.stocks)
            let portfolioJsonString = String(data: portfolioData, encoding: .utf8) ?? "No portfolio data"
            
            await GeminiRepo.analyzePortfolio(portfolioData: portfolioJsonString) { result in
                switch result {
                    case .success(let analysis):
                        print("AI Analysis Result: \(analysis)")
                        print("Portfolio Analysis Success:")
                    case .failure(let error):
                        print("Portfolio Analysis Error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error encoding portfolio data: \(error)")
        }
    }
}

#Preview {
    HomePage()
}
