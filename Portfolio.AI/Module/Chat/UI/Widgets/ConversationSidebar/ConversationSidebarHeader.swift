//
//  header.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 21/9/25.
//

import SwiftUI

struct ConversationSidebarHeader: View {
    @Binding var isPresented: Bool
    var body: some View {
        HStack {
            Text("Conversations")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.top, AppSpacing.medium)
        .padding(.bottom, AppSpacing.small)
    }
}


