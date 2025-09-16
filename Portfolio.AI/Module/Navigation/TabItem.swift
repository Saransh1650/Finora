//
//  NavigationTabs.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import Foundation

enum TabItem: String, CaseIterable {
    case home = "home"
    case portfolio = "portfolio"
    case settings = "settings"
    
    var title: String {
        switch self {
            case .home:
                return "Home"
            case .portfolio:
                return "Portfolio"
            case .settings:
                return "Settings"
        }
    }
    
    var icon: String {
        switch self {
            case .home:
                return "house"
            case .portfolio:
                return "chart.pie"
            case .settings:
                return "gearshape"
        }
    }
    
    var selectedIcon: String {
        switch self {
            case .home:
                return "house.fill"
            case .portfolio:
                return "chart.pie.fill"
            case .settings:
                return "gearshape.fill"
        }
    }
}
