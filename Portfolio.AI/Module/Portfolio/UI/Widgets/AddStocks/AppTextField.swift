//
//  AppTextField.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct AppTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var prefix: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 8) {
                if !prefix.isEmpty {
                    Text(prefix)
                        .foregroundColor(AppColors.textSecondary)
                        .font(.system(size: 16))
                }
                
                TextField(placeholder, text: $text)
                    .foregroundColor(AppColors.textPrimary)
                    .keyboardType(keyboardType)
                    .tint(AppColors.selected)
            }
            .padding(12)
            .background(AppColors.pureBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }
}
