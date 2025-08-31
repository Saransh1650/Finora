//
//  ThemeManager.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 8/31/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: ColorScheme?
    
    private let themeKey = "app_theme_preference"
    
    init() {
        loadTheme()
    }
    
    // MARK: - Theme Management
    
    /// Toggle between light and dark mode
    func toggleTheme() {
        switch currentTheme {
            case .light:
                setTheme(.dark)
            case .dark:
                setTheme(.light)
            case .none:
                setTheme(.dark)
            @unknown default:
                setTheme(.dark)
        }
    }
    
    /// Set specific theme
    func setTheme(_ theme: ColorScheme?) {
        currentTheme = theme
        saveTheme()
        applyTheme()
    }
    
    /// Set to system theme (follows device setting)
    func setSystemTheme() {
        currentTheme = nil
        saveTheme()
        applyTheme()
    }
    
    /// Get current theme as string for display
    var currentThemeString: String {
        switch currentTheme {
            case .light:
                return "Light"
            case .dark:
                return "Dark"
            case .none:
                return "System"
            @unknown default:
                return "System"
        }
    }
    
    /// Check if current theme is dark
    var isDarkMode: Bool {
        return currentTheme == .dark
    }
    
    /// Check if current theme is light
    var isLightMode: Bool {
        return currentTheme == .light
    }
    
    /// Check if using system theme
    var isSystemTheme: Bool {
        return currentTheme == nil
    }
    
    // MARK: - Private Methods
    
    private func loadTheme() {
        if let themeRawValue = UserDefaults.standard.object(forKey: themeKey) as? Int {
            switch themeRawValue {
                case 0:
                    currentTheme = .light
                case 1:
                    currentTheme = .dark
                default:
                    currentTheme = nil // System theme
            }
        } else {
            currentTheme = nil // Default to system theme
        }
    }
    
    private func saveTheme() {
        if let theme = currentTheme {
            let themeValue = theme == .light ? 0 : 1
            UserDefaults.standard.set(themeValue, forKey: themeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: themeKey)
        }
    }
    
    private func applyTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        if let theme = currentTheme {
            window.overrideUserInterfaceStyle = theme == .light ? .light : .dark
        } else {
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
}

// MARK: - Theme Manager Extension for SwiftUI

extension ThemeManager {
    /// Create a toggle button for theme switching
    func createThemeToggleButton() -> some View {
        Button(action: toggleTheme) {
            HStack {
                Image(systemName: themeIconName)
                Text(currentThemeString)
            }
        }
    }
    
    /// Get appropriate SF Symbol for current theme
    var themeIconName: String {
        switch currentTheme {
            case .light:
                return "sun.max.fill"
            case .dark:
                return "moon.fill"
            case .none:
                return "circle.lefthalf.filled"
            @unknown default:
                return "circle.lefthalf.filled"
        }
    }
}
