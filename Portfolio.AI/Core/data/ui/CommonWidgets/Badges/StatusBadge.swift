//
//  StatusBadge.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

enum BadgeStatus {
    case ready
    case pending
    case success
    case warning
    case error
    
    var color: Color {
        switch self {
        case .ready: return AppColors.selected
        case .pending: return .orange
        case .success: return .green
        case .warning: return .yellow
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .ready: return "checkmark.circle.fill"
        case .pending: return "clock.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "x.circle.fill"
        }
    }
}

struct StatusBadge: View {
    let text: String
    let status: BadgeStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.icon)
                .font(.caption)
                .foregroundColor(AppColors.pureBackground)
            
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.pureBackground)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(status.color)
        )
    }
}

// MARK: - Convenience Initializers
extension StatusBadge {
    static func ready() -> StatusBadge {
        StatusBadge(text: "Ready", status: .ready)
    }
    
    static func pending(_ text: String = "Pending") -> StatusBadge {
        StatusBadge(text: text, status: .pending)
    }
    
    static func success(_ text: String = "Success") -> StatusBadge {
        StatusBadge(text: text, status: .success)
    }
    
    static func warning(_ text: String = "Warning") -> StatusBadge {
        StatusBadge(text: text, status: .warning)
    }
    
    static func error(_ text: String = "Error") -> StatusBadge {
        StatusBadge(text: text, status: .error)
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusBadge.ready()
        StatusBadge.pending("Building")
        StatusBadge.success("Complete")
        StatusBadge.warning("Check Required")
        StatusBadge.error("Failed")
    }
    .padding()
    .background(AppColors.pureBackground)
}
