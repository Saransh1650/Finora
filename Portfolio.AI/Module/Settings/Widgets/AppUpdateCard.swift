//
//  AppUpdateCard.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 10/1/25.
//

import SwiftUI

struct AppUpdateCard: View {
    @ObservedObject var appUpdateManager: AppUpdateManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Update check row
            SettingsRow(
                icon: "arrow.down.circle.fill",
                title: "Check for Updates",
                subtitle: getUpdateSubtitle(),
                trailing: {
                    if appUpdateManager.isCheckingForUpdate {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                },
                action: {
                    if !appUpdateManager.isCheckingForUpdate {
                        appUpdateManager.checkForUpdatesManually()
                    }
                }
            )
            
            // Test buttons (only in debug mode)
            #if DEBUG
            Divider()
            
            VStack(spacing: 8) {
                Text("Debug Testing")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 12) {
                    Button("Test Optional Update") {
                        appUpdateManager.showTestUpdateDialog(isForceUpdate: false)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    
                    Button("Test Force Update") {
                        appUpdateManager.showTestUpdateDialog(isForceUpdate: true)
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            #endif
        }
        .settingsCardStyle()
        
    }
    
    private func getCurrentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private func getUpdateSubtitle() -> String {
        if appUpdateManager.isCheckingForUpdate {
            return "Checking for updates..."
        } else if let lastCheckDate = appUpdateManager.getLastUpdateCheckDate() {
            return "Last checked: \(formatDate(lastCheckDate))"
        } else {
            return "Tap to check for latest version"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    AppUpdateCard(appUpdateManager: AppUpdateManager())
        .padding()
        .background(AppColors.pureBackground)
}
