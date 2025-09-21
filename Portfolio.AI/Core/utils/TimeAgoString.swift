//
//  TimeAgoStrin.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 20/9/25.
//

import Foundation

class TimeAgoString {
    static func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
