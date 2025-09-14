//
//  LoadingView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct LoadingView: View {
    let title: String
    let subtitle: String?
    
    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Loading animation
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
            
            // Text content
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.background)
                .shadow(color: AppColors.textPrimary.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}





#Preview {
    VStack(spacing: 20) {
        LoadingView(title: "Loading Data")
                
    }
    .padding()
    .background(AppColors.pureBackground)
}
