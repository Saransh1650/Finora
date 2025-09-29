//
//  SettingsRow.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/9/25.
//

import SwiftUI

struct SettingsRow<TrailingContent: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder let trailing: () -> TrailingContent
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder trailing: @escaping () -> TrailingContent = { EmptyView() },
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.pureBackground.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Trailing content
                trailing()
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Card Style
struct SettingsCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.background)
                    .shadow(color: AppColors.textPrimary.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.border.opacity(0.3), lineWidth: 1)
            )
    }
}

extension View {
    func settingsCardStyle() -> some View {
        modifier(SettingsCardStyle())
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    VStack(spacing: 16) {
        SettingsRow(
            icon: "moon.fill",
            title: "Dark Mode",
            subtitle: "Switch between light and dark themes",
            trailing: {
                Toggle("", isOn: .constant(false))
                    .labelsHidden()
                    .tint(AppColors.background)
            }
        )
        
        SettingsRow(
            icon: "crown.fill",
            title: "Portfolio.AI Pro",
            subtitle: "Unlock premium AI insights",
            trailing: {
                StatusBadge(text: "Pro", status: .success)
            },
            action: {
                print("Pro tapped")
            }
        )
        
        SettingsRow(
            icon: "envelope.fill",
            title: "Contact Support",
            subtitle: "Get personalized help",
            trailing: {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            },
            action: {
                print("Support tapped")
            }
        )
    }
    .settingsCardStyle()
    .padding()
    .background(AppColors.pureBackground)
}
