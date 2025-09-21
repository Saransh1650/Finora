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
    case chat = "chat"
    
    var title: String {
        switch self {
            case .home:
                return "Home"
            case .portfolio:
                return "Portfolio"
            case .settings:
                return "Settings"
            case .chat:
                return "Chat"
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
            case .chat:
                return "message"
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
            case .chat:
                return "message.fill"
        }
    }
}
