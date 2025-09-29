//
//  ThemeSettingCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 16/9/25.
//

import SwiftUI

struct ThemeSettingsCard: View {
    @EnvironmentObject var themeManager : ThemeManager
    var user = SupabaseManager.shared.client
    var body: some View {
        VStack(spacing: 16) {
            SettingsRow(
                icon: "at",
                title: user.auth.currentUser!.email!,
                subtitle: "Your email address",
            )
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
        }
        .settingsCardStyle()
    }
}
