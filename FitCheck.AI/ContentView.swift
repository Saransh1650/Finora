//
//  ContentView.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 30/8/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                NavigationPage()
            } else {
                LoginPage()
            }
        }
        .environmentObject(authManager)
    }
}

#Preview {
    ContentView()
}
