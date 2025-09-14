//
//  AnalysisButtonSection.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct AnalysisButtonSection: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var portfolioAnalysisManager: PortfolioAnalysisManager
    
    var body: some View {
        VStack(spacing: 16) {
            if portfolioAnalysisManager.isLoading {
                // Loading State
                LoadingStateView()
            } else {
                // Analyze Button
                AnalyzeButton()
                
                // Error Message
                if let errorMessage = portfolioAnalysisManager.errorMessage {
                    ErrorMessageView(errorMessage: errorMessage)
                }
            }
        }
    }
}

// MARK: - Loading State View
struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.selected))
            
            VStack(spacing: 8) {
                Text("Analyzing Your Portfolio...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.foreground)
                
                Text("This may take a few moments while our AI processes your data")
                    .font(.body)
                    .foregroundStyle(AppColors.tertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.pureBackground)
                .shadow(color: AppColors.divider.opacity(0.1), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Analyze Button
struct AnalyzeButton: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var portfolioAnalysisManager: PortfolioAnalysisManager
    
    var body: some View {
        Button {
            Task {
                await portfolioAnalysisManager.generateSummaryAndSave(
                    stocks: portfolioManager.stocks
                )
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Analyze Portfolio with AI")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [AppColors.selected, AppColors.selected.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: AppColors.selected.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: portfolioAnalysisManager.isLoading)
    }
}

// MARK: - Error Message View
struct ErrorMessageView: View {
    let errorMessage: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            
            Text(errorMessage)
                .font(.body)
                .foregroundStyle(.red)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.red.opacity(0.1))
                .stroke(.red.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    AnalysisButtonSection()
        .environmentObject(PortfolioManager())
        .environmentObject(PortfolioAnalysisManager())
}