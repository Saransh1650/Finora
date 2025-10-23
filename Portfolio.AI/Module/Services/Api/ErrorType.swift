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
    case AppleSignInError
    case GoogleSignInError
    case InvalidCredentials
    case SignOutError
    case GetCurrentUserError
    case RefreshSessionError
    case DeleteAccountError
    case UpdateUserProfileError
    case NoCurrentUser
    case googleIdTokenNotFound
    case AppleIDTokenNotFound
    case fetchError
    case insertError
    case updateError
    case deleteError
    case authError
    case validationError
    case fileUploadError
    case fileSizeError
    case fileTypeError
    case sessionError
    case networkError
    case limitExceed
    case geminiDataParseError
    case parseError

    var message: String {
        switch self {
        case .invalidInput: return "Invalid input."
        case .unAuthorized: return "Unauthorized."
        case .notFound: return "Not found."
        case .conflict: return "Conflict."
        case .tooManyRequests: return "Too many requests."
        case .serverError: return "Server error."
        case .unKnownError: return "Unknown error."
        case .AppleSignInError: return "Apple Sign In error."
        case .GoogleSignInError: return "Google Sign In error."
        case .InvalidCredentials: return "Invalid credentials."
        case .SignOutError: return "Sign out error."
        case .GetCurrentUserError: return "Failed to get current user."
        case .RefreshSessionError: return "Failed to refresh session."
        case .DeleteAccountError: return "Failed to delete account."
        case .UpdateUserProfileError: return "Failed to update user profile."
        case .NoCurrentUser: return "No current user."
        case .googleIdTokenNotFound: return "Google ID token not found."
        case .AppleIDTokenNotFound: return "Apple ID token not found."
        case .fetchError: return "Failed to fetch data."
        case .insertError: return "Failed to insert data."
        case .updateError: return "Failed to update data."
        case .deleteError: return "Failed to delete data."
        case .authError: return "Authentication error."
        case .validationError: return "Validation error."
        case .fileUploadError: return "Failed to upload file."
        case .fileSizeError: return "File size exceeds limit."
        case .fileTypeError: return "File type not supported."
        case .sessionError: return "Session error."
        case .networkError: return "Network error."
        case .limitExceed: return "Limit exceeded."
        case .geminiDataParseError: return "Failed to parse Gemini data."
        case .parseError: return "Data parsing error."
        }
    }
}
