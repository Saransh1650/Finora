//
//  AuthRepo.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 1/9/25.
//

import AuthenticationServices
import Combine
import Foundation
import GoogleSignIn
import Supabase

// MARK: - AuthRepo Implementation
@MainActor
class AuthRepo {
    static let supabase = SupabaseClient(
        supabaseURL: URL(string: AppConfig.supabaseInitUrl)!,
        supabaseKey: AppConfig.anonKey
    )
    static var currentUser: User?

    // MARK: - Session Check
    static func checkExistingSession() async {
        do {
            let user = try await supabase.auth.user()
            currentUser = user
        } catch {
            currentUser = nil
        }
    }

    // MARK: - Sign In Methods
    static func signInWithApple(authorization: ASAuthorization) async
        -> (User?, Failure?)
    {
        guard
            let credential = authorization.credential
                as? ASAuthorizationAppleIDCredential
        else {
            return (
                nil,
                Failure(
                    message: ErrorType.AppleSignInError.message,
                    errorType: ErrorType.AppleSignInError
                )
            )
        }

        guard let identityToken = credential.identityToken,
            let tokenString = String(data: identityToken, encoding: .utf8)
        else {
            return (
                nil,
                Failure(
                    message: ErrorType.unAuthorized.message,
                    errorType: ErrorType.unAuthorized
                )
            )
        }

        do {
            guard
                let idToken = credential.identityToken
                    .flatMap({ String(data: $0, encoding: .utf8) })
            else {
                return (
                    nil,
                    Failure(
                        message: ErrorType.AppleIDTokenNotFound.message,
                        errorType: ErrorType.AppleIDTokenNotFound
                    )
                )
            }
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idToken
                )
            )

            return (session.user, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: ErrorType.AppleSignInError.message,
                    errorType: ErrorType.AppleSignInError
                )
            )
        }
    }

    static func signInWithGoogle() async
        -> (User?, Failure?)
    {
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: UIViewController()
            )

            guard let idToken = result.user.idToken?.tokenString else {
                return (
                    nil,
                    Failure(
                        message: ErrorType.unAuthorized.message,
                        errorType: ErrorType.unAuthorized
                    )
                )
            }
            let accessToken = result.user.accessToken.tokenString
            let session = try await supabase.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken
                )
            )

            return (session.user, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: ErrorType.unKnownError.message,
                    errorType: ErrorType.unKnownError
                )
            )
        }
    }

    // MARK: - Session Management
    static func signOut() async -> Failure? {
        do {
            try await supabase.auth.signOut()
            return nil
        } catch {
            return Failure(
                message: ErrorType.unKnownError.message,
                errorType: ErrorType.unKnownError
            )
        }
    }

    static func getCurrentUser() async -> (User?, Failure?) {
        do {
            let user = try await supabase.auth.user()
            return (user, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: ErrorType.unAuthorized.message,
                    errorType: ErrorType.unAuthorized
                )
            )
        }
    }

    static func refreshSession() async -> (User?, Failure?) {
        do {
            let session = try await supabase.auth.refreshSession()
            return (session.user, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: ErrorType.unKnownError.message,
                    errorType: ErrorType.unKnownError
                )
            )
        }
    }

    // MARK: - Account Management
    static func deleteAccount() async -> Failure? {
        guard let currentUser = currentUser else {
            return Failure(
                message: ErrorType.unAuthorized.message,
                errorType: ErrorType.unAuthorized
            )
        }

        do {
            try await supabase.auth.admin.deleteUser(id: currentUser.id)
            return nil
        } catch {
            return Failure(
                message: ErrorType.unKnownError.message,
                errorType: ErrorType.unKnownError
            )
        }
    }

    static func updateUserProfile(fullName: String?, avatarUrl: String?) async
        -> (
            User?, Failure?
        )
    {
        do {
            var userMetadata: [String: AnyJSON] = [:]

            if let fullName = fullName {
                userMetadata["full_name"] = .string(fullName)
            }

            if let avatarUrl = avatarUrl {
                userMetadata["avatar_url"] = .string(avatarUrl)
            }

            let updatedUser = try await supabase.auth.update(
                user: UserAttributes(data: userMetadata)
            )

            return (updatedUser, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: ErrorType.unKnownError.message,
                    errorType: ErrorType.unKnownError
                )
            )
        }
    }

}
