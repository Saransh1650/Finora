//
//  PortfolioStatusCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct PortfolioStatusCard: View {
    let currentStocks: Int
    let requiredStocks: Int
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress Header
            HStack {
                Text("Portfolio Progress")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                ProgressBadge(current: currentStocks, total: requiredStocks)
            }
            
            // Progress Bar
            ProgressBarWithSteps(current: currentStocks, total: requiredStocks)
            
            // Stats Row
            HStack {
                StatsColumn(
                    title: "Added",
                    value: "\(currentStocks)",
                    color: AppColors.selected
                )
                
                Spacer()
                
                ProgressIndicatorDots(current: currentStocks, total: requiredStocks)
                
                Spacer()
                
                StatsColumn(
                    title: "Required",
                    value: "\(requiredStocks)",
                    color: AppColors.textSecondary
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.background)
                .shadow(color: AppColors.textPrimary.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Progress Badge
struct ProgressBadge: View {
    let current: Int
    let total: Int
    
    private var percentage: Int {
        Int((Double(current) / Double(total)) * 100)
    }
    
    var body: some View {
        Text("\(percentage)%")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(current >= total ? AppColors.selected : AppColors.textSecondary)
            )
    }
}

// MARK: - Progress Bar with Steps
struct ProgressBarWithSteps: View {
    let current: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.border.opacity(0.3))
                        .frame(height: 8)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.selected, AppColors.selected.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * (Double(current) / Double(total)),
                            height: 8
                        )
                        .animation(.easeInOut(duration: 0.5), value: current)
                }
            }
            .frame(height: 8)
            
            // Step indicators
            HStack {
                ForEach(0..<total, id: \.self) { index in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(index < current ? AppColors.selected : AppColors.border)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(AppColors.background, lineWidth: 2)
                            )
                            .scaleEffect(index < current ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3), value: current)
                        
                        Text("Stock \(index + 1)")
                            .font(.caption2)
                            .foregroundColor(index < current ? AppColors.selected : AppColors.textSecondary)
                    }
                    
                    if index < total - 1 {
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Stats Column
struct StatsColumn: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Progress Indicator Dots
struct ProgressIndicatorDots: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < current ? AppColors.selected : AppColors.border)
                    .frame(width: 8, height: 8)
                    .scaleEffect(index < current ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: current)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PortfolioStatusCard(currentStocks: 1, requiredStocks: 2)
        PortfolioStatusCard(currentStocks: 2, requiredStocks: 2)
    }
    .padding()
    .background(AppColors.pureBackground)
}
