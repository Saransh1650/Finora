//
//  SideDrawer.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct SideAppDrawer: View {
    @Binding var isOpen: Bool
    @StateObject private var themeManager = ThemeManager()
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        HStack {
            // Drawer Content
            VStack(alignment: .leading, spacing: 0) {
                // Header
                UserInfoSideBar(isOpen: $isOpen)

                // Divider
                Rectangle()
                    .fill(AppColors.divider)
                    .frame(height: 1)
                    .padding(.horizontal, 20)

                // Menu Items
                VStack(alignment: .leading, spacing: 0) {
                    DrawerMenuItem(
                        icon: "person.fill",
                        title: "Profile",
                        action: {
                            // Handle profile navigation
                        }
                    )

                    DrawerMenuItem(
                        icon: themeManager.themeIconName,
                        title: "Theme: \(themeManager.currentThemeString)",
                        action: {
                            themeManager.toggleTheme()
                        }
                    )

                    DrawerMenuItem(
                        icon: "document.on.clipboard",
                        title: "Terms & Conditions",
                        action: {
                            // Handle help navigation
                        }
                    )

                    Spacer()

                    // Logout
                    DrawerMenuItem(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "Logout",
                        action: {
                            Task {
                                let error = await authManager.signOut()
                                if error != nil {
                                    print(
                                        "Error signing out: \(error!.localizedDescription)"
                                    )
                                }
                            }

                        }
                    )
                }
                .padding(.top, 20)

                Spacer()
            }
            .frame(width: 280)
            .background(AppColors.pureBackground)

            Spacer()
        }
    }
}

#Preview {
    SideAppDrawer(isOpen: .constant(true))
}
