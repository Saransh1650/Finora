//
//  AppUpdateManager.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 10/1/25.
//

import SwiftUI
import Foundation

@MainActor
class AppUpdateManager: ObservableObject {
    @Published var showUpdateDialog = false
    @Published var updateResult: UpdateCheckResult?
    @Published var isCheckingForUpdate = false
    
    private let updateService = AppUpdateService.shared
    private let userDefaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private enum UserDefaultsKeys {
        static let lastUpdateCheckDate = "lastUpdateCheckDate"
        static let skippedVersion = "skippedVersion"
    }
    
    // MARK: - Public Methods
    
    /// Check for updates automatically (respects user preferences and timing)
    func checkForUpdatesAutomatically() {
        Task {
            await performUpdateCheck(isManual: false)
        }
    }
    
    /// Check for updates manually (always shows result)
    func checkForUpdatesManually() {
        Task {
            await performUpdateCheck(isManual: true)
        }
    }
    
    /// Show update dialog for testing purposes
    func showTestUpdateDialog(isForceUpdate: Bool = false) {
        let testResult = updateService.checkForUpdateWithCustomLogic(forceUpdate: isForceUpdate)
        updateResult = testResult
        showUpdateDialog = true
    }
    
    // MARK: - Private Methods
    
    private func performUpdateCheck(isManual: Bool) async {
        // Don't check too frequently for automatic checks
        if !isManual && !shouldCheckForUpdate() {
            return
        }
        
        isCheckingForUpdate = true
        
        let result = await updateService.checkForUpdate()
        
        isCheckingForUpdate = false
        
        // Update last check date
        userDefaults.set(Date(), forKey: UserDefaultsKeys.lastUpdateCheckDate)
        
        // Check if we should show the dialog
        if shouldShowUpdateDialog(for: result, isManual: isManual) {
            updateResult = result
            showUpdateDialog = true
        }
    }
    
    private func shouldCheckForUpdate() -> Bool {
        let lastCheckDate = userDefaults.object(forKey: UserDefaultsKeys.lastUpdateCheckDate) as? Date ?? Date.distantPast
        let hoursSinceLastCheck = Date().timeIntervalSince(lastCheckDate) / 3600
        
        // Check at most once every 24 hours for automatic checks
        return hoursSinceLastCheck >= 24
    }
    
    private func shouldShowUpdateDialog(for result: UpdateCheckResult, isManual: Bool) -> Bool {
        // Always show for manual checks
        if isManual {
            return result.isUpdateRequired
        }
        
        // For automatic checks
        guard result.isUpdateRequired else { return false }
        
        // Always show force updates
        if result.isForceUpdate {
            return true
        }
        
        // Don't show if user already skipped this version
        let skippedVersion = userDefaults.string(forKey: UserDefaultsKeys.skippedVersion)
        if skippedVersion == result.latestVersion {
            return false
        }
        
        return true
    }
    
    // MARK: - Dialog Actions
    
    func handleUpdatePressed() {
        guard let updateResult = updateResult,
              let urlString = updateResult.updateUrl,
              let url = URL(string: urlString) else {
            return
        }
        
        // Open App Store or update URL
        UIApplication.shared.open(url)
        
        // Don't dismiss dialog for force updates
        if !updateResult.isForceUpdate {
            dismissUpdateDialog()
        }
    }
    
    func handleLaterPressed() {
        guard let updateResult = updateResult else { return }
        
        // Remember that user skipped this version
        userDefaults.set(updateResult.latestVersion, forKey: UserDefaultsKeys.skippedVersion)
        
        dismissUpdateDialog()
    }
    
    func dismissUpdateDialog() {
        showUpdateDialog = false
        updateResult = nil
    }
    
    // MARK: - Utility Methods
    
    func resetSkippedVersion() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.skippedVersion)
    }
    
    func getLastUpdateCheckDate() -> Date? {
        return userDefaults.object(forKey: UserDefaultsKeys.lastUpdateCheckDate) as? Date
    }
}