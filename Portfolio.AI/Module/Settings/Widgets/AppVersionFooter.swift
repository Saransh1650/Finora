//
//  AppVersionFooter.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 16/9/25.
//

import SwiftUI

struct AppVersionFooter: View {
    var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }
    var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    }
    var body: some View {
        VStack(spacing: 8) {
            Text("Finora")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textSecondary)
            
            Text("Version \(version) (Build \(build))")
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


