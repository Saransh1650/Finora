//
//  app_button.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 11/8/25.
//

import SwiftUI

struct AppButton: View {
    let title: String
    let action: () -> Void
    let icon: String?
    let image: String?
    let style: AppButtonStyle
    let isLoading: Bool
    let hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle?

    @State private var isPressed = false

    init(
        title: String,
        action: @escaping () -> Void,
        icon: String? = nil,
        image: String? = nil,
        style: AppButtonStyle = .primary,
        isLoading: Bool = false,
        hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle? = .medium
    ) {
        self.title = title
        self.action = action
        self.icon = icon
        self.image = image
        self.style = style
        self.isLoading = isLoading
        self.hapticFeedback = hapticFeedback
    }

    var body: some View {
        Button(action: {
            if let hapticStyle = hapticFeedback {
                HapticManager.shared.impact(hapticStyle)
            }
            action()
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: style.foregroundColor
                            )
                        )
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: style.iconSize, weight: .semibold))
                        .foregroundColor(style.foregroundColor)
                        .scaleEffect(isPressed ? 1.2 : 1.0)
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.6),
                            value: isPressed
                        )
                } else if let image = image {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: style.iconSize, height: style.iconSize)
                        .foregroundColor(style.foregroundColor)
                        .scaleEffect(isPressed ? 1.2 : 1.0)
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.6),
                            value: isPressed
                        )
                }

                Text(isLoading ? "Loading..." : title)
                    .font(.system(size: style.fontSize, weight: .semibold))
                    .foregroundColor(style.foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: style.height)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.backgroundColor)
                    .shadow(
                        color: style.shadowColor,
                        radius: style.shadowRadius,
                        x: 0,
                        y: style.shadowOffset
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderGradient, lineWidth: style.borderWidth)
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                if !isLoading {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

// MARK: - App Button Style
enum AppButtonStyle {
    case primary
    case secondary
    case accent
    case destructive
    case ghost
    case outline

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
        case .destructive:
            return LinearGradient(
                colors: [.red, .red.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ghost, .outline:
            return LinearGradient(
                colors: [Color.clear, Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary, .accent, .destructive:
            return AppColors.pureBackground
        case .secondary:
            return AppColors.textPrimary
        case .ghost:
            return AppColors.selected
        case .outline:
            return AppColors.selected
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
        case .destructive:
            return .red.opacity(0.3)
        case .ghost, .outline:
            return Color.clear
        }
    }

    var borderGradient: LinearGradient {
        switch self {
        case .primary, .accent, .destructive:
            return LinearGradient(
                colors: [.white.opacity(0.2), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        case .secondary:
            return LinearGradient(
                colors: [
                    AppColors.border.opacity(0.3),
                    AppColors.border.opacity(0.3),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .ghost:
            return LinearGradient(
                colors: [Color.clear, Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        case .outline:
            return LinearGradient(
                colors: [AppColors.selected, AppColors.selected],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .primary, .accent, .destructive, .secondary:
            return 1
        case .ghost:
            return 0
        case .outline:
            return 1.5
        }
    }

    var height: CGFloat {
        return 56
    }

    var cornerRadius: CGFloat {
        return 16
    }

    var fontSize: CGFloat {
        return 17
    }

    var iconSize: CGFloat {
        return 18
    }

    var shadowRadius: CGFloat {
        switch self {
        case .primary, .accent, .destructive:
            return 12
        case .secondary:
            return 8
        case .ghost, .outline:
            return 0
        }
    }

    var shadowOffset: CGFloat {
        switch self {
        case .primary, .accent, .destructive:
            return 6
        case .secondary:
            return 2
        case .ghost, .outline:
            return 0
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AppButton(
            title: "Primary Button",
            action: { print("Primary tapped") },
            icon: "plus.circle.fill",
            style: .primary
        )

        AppButton(
            title: "Secondary Button",
            action: { print("Secondary tapped") },
            icon: "heart",
            style: .secondary
        )

        AppButton(
            title: "Accent Button",
            action: { print("Accent tapped") },
            icon: "sparkles",
            style: .accent
        )

        AppButton(
            title: "Destructive Button",
            action: { print("Destructive tapped") },
            icon: "trash",
            style: .destructive
        )

        AppButton(
            title: "Ghost Button",
            action: { print("Ghost tapped") },
            icon: "arrow.right",
            style: .ghost
        )

        AppButton(
            title: "Outline Button",
            action: { print("Outline tapped") },
            icon: "checkmark",
            style: .outline
        )

        AppButton(
            title: "Loading...",
            action: {},
            icon: "globe",
            style: .primary,
            isLoading: true
        )
    }
    .padding()
    .background(AppColors.pureBackground)
}
