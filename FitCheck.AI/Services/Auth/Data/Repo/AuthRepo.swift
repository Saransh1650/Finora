//
//  AuthRepo.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 1/9/25.
//

import AuthenticationServices
import Combine
import Foundation
import Supabase

// MARK: - AuthRepo Implementation
@MainActor
class AuthRepo {
    private let supabase: SupabaseClient
    private var currentUser: User?

    // MARK: - Initialization
    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: "https://your-project.supabase.co")!,
            supabaseKey: "your-anon-key"
        )
        Task {
            await checkExistingSession()
        }
    }

    // MARK: - Session Check
    private func checkExistingSession() async {
        do {
            let user = try await supabase.auth.user()
            currentUser = user
        } catch {
            currentUser = nil
        }
    }

    // MARK: - Sign In Methods
    func signInWithApple(authorization: ASAuthorization) async
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
            let session = try await supabase.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: tokenString
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

    func signInWithGoogle(idToken: String, accessToken: String) async
        -> (User?, Failure?)
    {
        do {
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
    func signOut() async -> Failure? {
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

    func getCurrentUser() async -> (User?, Failure?) {
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

    func refreshSession() async -> (User?, Failure?) {
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
    func deleteAccount() async -> Failure? {
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

    func updateUserProfile(fullName: String?, avatarUrl: String?) async -> (
        User?, Failure?
    ) {
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
