//
//  AppColors.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import UIKit
import SwiftUI

enum AppColors {
    
    // MARK: - Brand Colors
    static let background = Color("background")
    static let foreground = Color("foreground")
    static let tertiary = Color("tertiary")
    
    // MARK: - App Specific Colors
    // 1) Pure background of the app
    static let pureBackground = Color("pureBackground")
    
    // 2) Secondary colors for dividers, spaces, etc
    static let divider = Color("divider")
    
    // 3) Selected components, buttons, etc
    static let selected = Color("selected")
    
    // MARK: - System Colors
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
}
