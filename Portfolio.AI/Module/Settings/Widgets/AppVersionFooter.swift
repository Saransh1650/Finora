//
//  AppVersionFooter.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 16/9/25.
//

import SwiftUI

struct AppVersionFooter: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Portfolio.AI")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textSecondary)
            
            Text("Version 1.0.0 (Build 1)")
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary.opacity(0.7))
            
            Text("Made with ❤️ for smart investors")
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary.opacity(0.7))
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
    }
}


