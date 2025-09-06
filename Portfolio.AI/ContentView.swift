//
//  ContentView.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 30/8/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authManager: AuthManager = AuthManager()
    var body: some View {
        Group {
            if authManager.loading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if authManager.isAuthenticated {
                NavigationPage()
            } else {
                LoginPage()
            }
        }
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
