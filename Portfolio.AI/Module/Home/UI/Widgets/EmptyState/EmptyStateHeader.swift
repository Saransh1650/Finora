//
//  EmptyStateHeader.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct EmptyStateHeader: View {
    let iconName: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let style: HeaderStyle
    
    init(
        iconName: String,
        title: String,
        subtitle: String,
        iconColor: Color = AppColors.selected,
        style: HeaderStyle = .default
    ) {
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated icon container
            ZStack {
                // Outer ring
                Circle()
                    .stroke(iconColor.opacity(0.1), lineWidth: 2)
                    .frame(width: 140, height: 140)
                
                // Middle ring with gradient
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [iconColor.opacity(0.15), iconColor.opacity(0.05)],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                // Inner circle with shadow
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 90, height: 90)
                    .shadow(color: iconColor.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: style.iconSize, weight: .medium))
                    .foregroundColor(iconColor)
                    .scaleEffect(style.iconScale)
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: iconName)
            
            // Text content
            VStack(spacing: 12) {
                Text(title)
                    .font(style.titleFont)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(style.subtitleFont)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, style.subtitlePadding)
            }
        }
        .padding(.top, style.topPadding)
    }
}

// MARK: - Header Styles
enum HeaderStyle {
    case `default`
    case compact
    case prominent
    
    var iconSize: CGFloat {
        switch self {
        case .default: return 50
        case .compact: return 40
        case .prominent: return 60
        }
    }
    
    var iconScale: CGFloat {
        switch self {
        case .default: return 1.0
        case .compact: return 0.9
        case .prominent: return 1.1
        }
    }
    
    var titleFont: Font {
        switch self {
        case .default: return .title
        case .compact: return .title2
        case .prominent: return .largeTitle
        }
    }
    
    var subtitleFont: Font {
        switch self {
        case .default: return .body
        case .compact: return .subheadline
        case .prominent: return .title3
        }
    }
    
    var subtitlePadding: CGFloat {
        switch self {
        case .default: return 20
        case .compact: return 16
        case .prominent: return 24
        }
    }
    
    var topPadding: CGFloat {
        switch self {
        case .default: return 40
        case .compact: return 20
        case .prominent: return 60
        }
    }
}

// MARK: - Success State Header
struct SuccessStateHeader: View {
    let title: String
    let subtitle: String
    let badgeText: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Success animation container
            ZStack {
                // Animated success rings
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(AppColors.selected.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                        .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                        .scaleEffect(1.0 + Double(index) * 0.05)
                        .animation(.easeOut(duration: 1.5).delay(Double(index) * 0.2), value: index)
                }
                
                // Success checkmark
                ZStack {
                    Circle()
                        .fill(AppColors.selected)
                        .frame(width: 80, height: 80)
                        .shadow(color: AppColors.selected.opacity(0.3), radius: 12, x: 0, y: 6)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.pureBackground)
                }
            }
            
            // Success content
            VStack(spacing: 16) {
                // Success badge
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.pureBackground)
                    
                    Text(badgeText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.pureBackground)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(AppColors.selected)
                        .shadow(color: AppColors.selected.opacity(0.3), radius: 4, x: 0, y: 2)
                )
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 40)
    }
}

#Preview {
    VStack(spacing: 40) {
        EmptyStateHeader(
            iconName: "chart.pie.fill",
            title: "Build Your Portfolio",
            subtitle: "Add at least 2 stocks to start analyzing your portfolio"
        )
        
        SuccessStateHeader(
            title: "Portfolio Ready!",
            subtitle: "You have 3 stocks in your portfolio. Start analyzing to get insights!",
            badgeText: "Ready to Analyze"
        )
    }
    .padding()
    .background(AppColors.pureBackground)
}
