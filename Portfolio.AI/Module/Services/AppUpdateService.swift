//
//  AppUpdateService.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 10/1/25.
//

import Foundation

class AppUpdateService: ObservableObject {
    static let shared = AppUpdateService()
    
    private init() {}
    
    // MARK: - Configuration
    private let appStoreId = "YOUR_APP_STORE_ID" // Replace with your actual App Store ID
    private var appStoreUrl: String {
        return "https://itunes.apple.com/lookup?id=\(appStoreId)"
    }
    
    // MARK: - Update Check
    func checkForUpdate() async -> UpdateCheckResult {
        do {
            let latestVersion = try await fetchLatestVersionFromAppStore()
            let currentVersion = getCurrentAppVersion()
            
            let isUpdateRequired = latestVersion.isNewerVersion
            let isForceUpdate = shouldForceUpdate(current: currentVersion, latest: latestVersion)
            
            return UpdateCheckResult(
                isUpdateRequired: isUpdateRequired,
                isForceUpdate: isForceUpdate,
                latestVersion: latestVersion,
                currentVersion: currentVersion,
                updateUrl: getAppStoreUpdateUrl(),
                releaseNotes: nil // Can be enhanced to fetch release notes
            )
        } catch {
            print("Failed to check for updates: \(error)")
            return UpdateCheckResult() // Return default result on error
        }
    }
    
    // MARK: - App Store Integration
    private func fetchLatestVersionFromAppStore() async throws -> String {
        guard let url = URL(string: appStoreUrl) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AppStoreResponse.self, from: data)
        
        guard let app = response.results.first else {
            throw NSError(domain: "AppUpdateService", code: 1, userInfo: [NSLocalizedDescriptionKey: "App not found in App Store"])
        }
        
        return app.version
    }
    
    private func getCurrentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private func getAppStoreUpdateUrl() -> String {
        return "https://apps.apple.com/app/id\(appStoreId)"
    }
    
    // MARK: - Force Update Logic
    private func shouldForceUpdate(current: String, latest: String) -> Bool {
        // Implement your force update logic here
        // For example, force update if major version is different
        let currentComponents = current.components(separatedBy: ".").compactMap { Int($0) }
        let latestComponents = latest.components(separatedBy: ".").compactMap { Int($0) }
        
        if currentComponents.count > 0 && latestComponents.count > 0 {
            // Force update if major version (first component) is different
            return currentComponents[0] < latestComponents[0]
        }
        
        return false
    }
    
    // MARK: - Manual Update Check (for testing)
    func checkForUpdateWithCustomLogic(forceUpdate: Bool = false) -> UpdateCheckResult {
        let currentVersion = getCurrentAppVersion()
        let mockLatestVersion = "2.0.0" // For testing purposes
        
        return UpdateCheckResult(
            isUpdateRequired: true,
            isForceUpdate: forceUpdate,
            latestVersion: mockLatestVersion,
            currentVersion: currentVersion,
            updateUrl: getAppStoreUpdateUrl(),
            releaseNotes: "• Bug fixes and performance improvements\n• New features added\n• Enhanced user experience"
        )
    }
}