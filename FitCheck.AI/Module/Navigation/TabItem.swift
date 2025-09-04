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
    
    var title: String {
        switch self {
            case .home:
                return "Home"
            case .portfolio:
                return "Portfolio"
        }
    }
    
    var icon: String {
        switch self {
            case .home:
                return "house"
            case .portfolio:
                return "chart.pie"
        }
    }
    
    var selectedIcon: String {
        switch self {
            case .home:
                return "house.fill"
            case .portfolio:
                return "chart.pie.fill"
        }
    }
}
