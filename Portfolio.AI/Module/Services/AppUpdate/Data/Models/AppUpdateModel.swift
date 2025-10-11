//
//  AppUpdateModel.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 10/1/25.
//

import Foundation

// MARK: - App Store Response Models
struct AppStoreResponse: Codable {
    let results: [AppStoreApp]
}

struct AppStoreApp: Codable {
    let version: String
    let trackViewUrl: String?
    let releaseNotes: String?
    let minimumOsVersion: String?
}

// MARK: - Update Check Result
struct UpdateCheckResult {
    let isUpdateRequired: Bool
    let isForceUpdate: Bool
    let latestVersion: String
    let currentVersion: String
    let updateUrl: String?
    let releaseNotes: String?
    
    init(
        isUpdateRequired: Bool = false,
        isForceUpdate: Bool = false,
        latestVersion: String = "",
        currentVersion: String = "",
        updateUrl: String? = nil,
        releaseNotes: String? = nil
    ) {
        self.isUpdateRequired = isUpdateRequired
        self.isForceUpdate = isForceUpdate
        self.latestVersion = latestVersion
        self.currentVersion = currentVersion
        self.updateUrl = updateUrl
        self.releaseNotes = releaseNotes
    }
}

// MARK: - Version Comparison Helper
extension String {
    func compareVersion(to version: String) -> ComparisonResult {
        let components1 = self.components(separatedBy: ".").compactMap { Int($0) }
        let components2 = version.components(separatedBy: ".").compactMap { Int($0) }
        
        let maxCount = max(components1.count, components2.count)
        
        for i in 0..<maxCount {
            let v1 = i < components1.count ? components1[i] : 0
            let v2 = i < components2.count ? components2[i] : 0
            
            if v1 < v2 {
                return .orderedAscending
            } else if v1 > v2 {
                return .orderedDescending
            }
        }
        
        return .orderedSame
    }
    
    var isNewerVersion: Bool {
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return false
        }
        return currentVersion.compareVersion(to: self) == .orderedAscending
    }
}
