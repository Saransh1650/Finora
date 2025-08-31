//
//  ErrorType.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import Foundation

enum ErrorType {
    case invalidInput
    case unAuthorized
    case notFound
    case conflict
    case tooManyRequests
    case serverError
    case unKnownError
    
    var message: String {
        switch self {
            case .invalidInput: return "Invalid input."
            case .unAuthorized: return "Unauthorized."
            case .notFound: return "Not found."
            case .conflict: return "Conflict."
            case .tooManyRequests: return "Too many requests."
            case .serverError: return "Server error."
            case .unKnownError: return "Unknown error."
        }
    }
}
