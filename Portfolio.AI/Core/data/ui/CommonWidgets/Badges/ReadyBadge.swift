//
//  ReadyBadge.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct ReadyBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.white)
            
            Text("Ready")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(AppColors.selected)
        )
    }
}

#Preview {
    ReadyBadge()
        .padding()
        .background(AppColors.pureBackground)
}
