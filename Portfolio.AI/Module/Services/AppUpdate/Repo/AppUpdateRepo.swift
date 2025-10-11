//
//  AppUpdateService.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 10/1/25.
//

import Foundation

class AppUpdateRepo {
    
    // MARK: - Configuration
    static private let appStoreId = AppConstants.appId
    static private var appStoreUrl: String {
        return "https://itunes.apple.com/lookup?id=\(appStoreId)"
    }
    
    // MARK: - Update Check
    static func checkForUpdate() async -> UpdateCheckResult {
        
        do {
            let latestVersion = try await fetchLatestVersionFromAppStore()
            
            let currentVersion = getCurrentAppVersion()
            
            let isUpdateRequired = isVersionNewer(current: currentVersion, latest: latestVersion)
            
            let isForceUpdate = shouldForceUpdate(current: currentVersion, latest: latestVersion)
            
            let result = UpdateCheckResult(
                isUpdateRequired: isUpdateRequired,
                isForceUpdate: isForceUpdate,
                latestVersion: latestVersion,
                currentVersion: currentVersion,
                updateUrl: getAppStoreUpdateUrl(),
                releaseNotes: nil // Can be enhanced to fetch release notes
            )
            return result
        } catch {
            return UpdateCheckResult() // Return default result on error
        }
    }
    
    // MARK: - App Store Integration
    static private func fetchLatestVersionFromAppStore() async throws -> String {
        guard let url = URL(string: appStoreUrl) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let jsonDecoded = try JSONDecoder().decode(AppStoreResponse.self, from: data)
        
        guard let app = jsonDecoded.results.first else {
            throw NSError(domain: "AppUpdateService", code: 1, userInfo: [NSLocalizedDescriptionKey: "App not found in App Store"])
        }
        
        return app.version
    }
    
    static private func getCurrentAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return version
    }
    
    static private func getAppStoreUpdateUrl() -> String {
        return "https://apps.apple.com/app/id\(appStoreId)"
    }
    
    // MARK: - Version Comparison
    static private func isVersionNewer(current: String, latest: String) -> Bool {
        
        let currentComponents = current.components(separatedBy: ".").compactMap { Int($0) }
        let latestComponents = latest.components(separatedBy: ".").compactMap { Int($0) }
        
        
        let maxCount = max(currentComponents.count, latestComponents.count)
        
        for i in 0..<maxCount {
            let currentVersion = i < currentComponents.count ? currentComponents[i] : 0
            let latestVersion = i < latestComponents.count ? latestComponents[i] : 0
            
            if latestVersion > currentVersion {
                return true
            } else if currentVersion > latestVersion {
                return false
            }
        }
        return false
    }
    
    // MARK: - Force Update Logic
    static private func shouldForceUpdate(current: String, latest: String) -> Bool {
        
        // Implement your force update logic here
        // For example, force update if major version is different
        let currentComponents = current.components(separatedBy: ".").compactMap { Int($0) }
        let latestComponents = latest.components(separatedBy: ".").compactMap { Int($0) }
    
        
        if currentComponents.count > 0 && latestComponents.count > 0 {
            // Force update if major version (first component) is different
            let shouldForce = currentComponents[0] < latestComponents[0]
            return shouldForce
        }
    
        return false
    }
    
    // MARK: - Manual Update Check (for testing)
    static func checkForUpdateWithCustomLogic(forceUpdate: Bool = false) -> UpdateCheckResult {
        let currentVersion = getCurrentAppVersion()
        let mockLatestVersion = "2.0.0" // For testing purposes
        
        return UpdateCheckResult(
            isUpdateRequired: true,
            isForceUpdate: forceUpdate,
            latestVersion: mockLatestVersion,
            currentVersion: currentVersion,
            updateUrl: getAppStoreUpdateUrl(),
            releaseNotes: "• Bug fixes and performance improvements\n• aNew features dded\n• Enhanced user experience"
        )
    }
}
