//
//  DateParser.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 26/9/25.
//

import Foundation
import Supabase

class DateParser{
     static func parseDate(from anyJson: AnyJSON?) -> Date? {
        guard let dateString = anyJson?.stringValue else { return nil }
        
        let iso8601Formatter = ISO8601DateFormatter()
        
        // Try with fractional seconds first
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }
        
        // Try without fractional seconds
        iso8601Formatter.formatOptions = [.withInternetDateTime]
        return iso8601Formatter.date(from: dateString)
    }
}
