//
//  ContentView.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 30/8/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authManager: AuthManager = AuthManager()
    @StateObject var themeManager: ThemeManager = ThemeManager()
    @State private var showOnboarding: Bool = false
    var body: some View {

        Group {
            if authManager.loading {
                PortfolioLoadingAnimation(showText: false)
                    .scaleEffect(1.5)
            } else if authManager.isAuthenticated {
                NavigationPage()
            } else if !showOnboarding {
                IntroOnboardingFlow {
                    showOnboarding = true
                }

            } else {
                LoginPage()
            }

        }
        .environmentObject(themeManager)
        .environmentObject(authManager)
        .onAppear {
            Task {
                await authManager.checkAuthStatus()
            }
        }
    
    }
}

#Preview {
    ContentView()
}
