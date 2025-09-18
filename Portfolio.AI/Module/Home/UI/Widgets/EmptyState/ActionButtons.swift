//
//  ActionButtons.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

// MARK: - Add Stock Action Button
struct AddStockActionButton: View {
    @State private var showingAddDialog = false
    let buttonText: String
    let style: ActionButtonStyle
    
    init(buttonText: String = "Add Your Next Stock", style: ActionButtonStyle = .primary) {
        self.buttonText = buttonText
        self.style = style
    }
    
    var body: some View {
        Button(action: {
            showingAddDialog = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.pureBackground)
                
                Text(buttonText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.pureBackground)
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(style.backgroundColor)
                    .shadow(color: style.shadowColor, radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(showingAddDialog ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: showingAddDialog)
        .fullScreenCover(isPresented: $showingAddDialog) {
            AddStockDialog()
                .background(ClearBackgroundView())
        }
    }
}

// MARK: - Start Analysis Button
struct StartAnalysisButton: View {
    @EnvironmentObject var portfolioAnalysisManager: PortfolioAnalysisManager
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            Task {
                await portfolioAnalysisManager.generateSummaryAndSave(stocks: portfolioManager.stocks)
            }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.pureBackground)
                        .scaleEffect(isPressed ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                }
                
                Text("Start AI Analysis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.pureBackground)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.selected, AppColors.selected.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: AppColors.selected.opacity(0.4), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Analyzing Loading View
struct AnalyzingLoadingView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(AppColors.selected.opacity(0.2), lineWidth: 3)
                        .frame(width: 28, height: 28)
                    
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(AppColors.selected, lineWidth: 3)
                        .frame(width: 28, height: 28)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotationAngle)
                }
                .onAppear {
                    rotationAngle = 360
                }
                
                Text("Analyzing Portfolio...")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.background)
                    .shadow(color: AppColors.textPrimary.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            
            VStack(spacing: 8) {
                Text("This may take a few moments while our AI processes your data")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(AppColors.selected.opacity(0.6))
                            .frame(width: 4, height: 4)
                            .scaleEffect(rotationAngle > Double(index * 120) ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2), value: rotationAngle)
                    }
                }
            }
        }
    }
}

// MARK: - Action Button Style
enum ActionButtonStyle {
    case primary
    case secondary
    case accent
    
    var backgroundColor: LinearGradient {
        switch self {
        case .primary:
            return LinearGradient(
                colors: [AppColors.selected, AppColors.selected.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            return LinearGradient(
                colors: [AppColors.background, AppColors.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .accent:
            return LinearGradient(
                colors: [.orange, .orange.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .accent:
            return .white
        case .secondary:
            return AppColors.textPrimary
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .primary:
            return AppColors.selected.opacity(0.3)
        case .secondary:
            return AppColors.textPrimary.opacity(0.1)
        case .accent:
            return .orange.opacity(0.3)
        }
    }
}

// MARK: - Haptic Manager


#Preview {
    VStack(spacing: 20) {
        AddStockActionButton()
        AddStockActionButton(buttonText: "Add Stock", style: .secondary)
        StartAnalysisButton()
            .environmentObject(PortfolioAnalysisManager())
            .environmentObject(PortfolioManager())
        AnalyzingLoadingView()
    }
    .padding()
    .background(AppColors.pureBackground)
}
