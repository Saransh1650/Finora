//
//  ConversationSidebarSearchbar.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 21/9/25.
//

import SwiftUI

struct ConversationSidebarSearchbar: View {
    @Binding var searchText: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textSecondary)
            
            TextField("Search conversations...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColors.foreground)
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

