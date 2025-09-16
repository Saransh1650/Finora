//
//  SettingsManager.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/9/25.
//

import SwiftUI
import Foundation

class SettingsManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var textSize: TextSize {
        didSet {
            UserDefaults.standard.set(textSize.rawValue, forKey: "textSize")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        
        let textSizeRaw = UserDefaults.standard.string(forKey: "textSize") ?? TextSize.medium.rawValue
        self.textSize = TextSize(rawValue: textSizeRaw) ?? .medium
    }
}

enum TextSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    
    var title: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
    
    var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.1
        }
    }
}