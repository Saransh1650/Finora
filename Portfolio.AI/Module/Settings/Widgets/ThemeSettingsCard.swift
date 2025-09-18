//
//  ThemeSettingCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 16/9/25.
//

import SwiftUI

struct ThemeSettingsCard: View {
    @EnvironmentObject var themeManager : ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            SettingsRow(
                icon: "moon.fill",
                title: "Dark Mode",
                subtitle: "Switch between light and dark themes",
                trailing: {
                    Toggle("", isOn: Binding(
                        get: { themeManager.isDarkMode },
                        set: { isOn in
                            themeManager.setTheme(isOn ? .dark : .light)
                        }
                    ))
                        .labelsHidden()
                        .tint(AppColors.pureBackground)
                    
                }) {
                    
                }
            
            SettingsRow(
                icon: "textformat.size",
                title: "Text Size",
                subtitle: "Adjust app text size",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    // Handle text size adjustment
                }
            )
        }
        .settingsCardStyle()
    }
}
