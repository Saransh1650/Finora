//
//  MainTabView.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import SwiftUI

struct NavigationPage: View {
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        VStack(spacing: 0) {
            // Content Area
            ZStack {
                switch selectedTab {
                    case .home:
                        NavigationView {
                            HomePage()
                        }
                    case .portfolio:
                        NavigationView {
                            PortfolioPage()
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Bottom Navigation
            CustomNavBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}


#Preview {
    NavigationPage()
}
