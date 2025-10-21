//
//  AuthManager.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 1/9/25.
//

import AuthenticationServices
import Combine
import Foundation
import Supabase
import SwiftUI

@MainActor
class AuthManager: ObservableObject {

    @Published var currentUser: User?
    @Published var loading: Bool = true
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var supabaseClient = AuthRepo.supabase

    func checkAuthStatus() async {
        Task {
            loading = true
            let (user, failure) = await AuthRepo.getCurrentUser()
            if failure == nil {
                currentUser = user
                isAuthenticated = user != nil
                loading = false
                LocalStorage.set(LocalStorageKeys.accessToken, value: supabaseClient.auth.currentSession!.accessToken)
            } else {
                currentUser = nil
                isAuthenticated = false
                errorMessage = failure?.message
                loading = false
            }
        }
    }

    // MARK: - Authentication Methods
    func signInWithApple(authorization: ASAuthorization) async -> Failure? {
        loading = true
        let (user, failure) = await AuthRepo.signInWithApple(
            authorization: authorization
        )

        if failure == nil {
            currentUser = user
            isAuthenticated = true
            errorMessage = nil
            let accessToken : String = supabaseClient.auth.currentSession!.accessToken
            LocalStorage.set(LocalStorageKeys.accessToken, value: accessToken)
        } else {
            errorMessage = failure?.message
        }
        loading = false
        return failure
    }

    func signOut() async -> Failure? {
        loading = true
        let failure = await AuthRepo.signOut()

        if failure == nil {
            currentUser = nil
            isAuthenticated = false
            errorMessage = nil
            print("Sign out successful")
        } else {
            errorMessage = failure?.message
            print("Sign out failed: \(failure?.message ?? "")")
        }
        loading = false
        return failure
    }

    func refreshSession() async -> Failure? {
        loading = true
        let (user, failure) = await AuthRepo.refreshSession()

        if failure == nil {
            currentUser = user
            errorMessage = nil
            print("Session refreshed successfully")
        } else {
            errorMessage = failure?.message
            print("Session refresh failed: \(failure?.message ?? "")")
        }
        loading = false
        return failure
    }

    // MARK: - Profile Management
    func updateProfile(fullName: String?, avatarUrl: String?) async -> Failure?
    {
        if currentUser == nil {
            return Failure(
                message: ErrorType.NoCurrentUser.message,
                errorType: ErrorType.NoCurrentUser
            )
        }
        loading = true
        let (user, failure) = await AuthRepo.updateUserProfile(
            fullName: fullName,
            avatarUrl: avatarUrl
        )

        if failure == nil {
            currentUser = user
            errorMessage = nil
            print("Profile updated successfully for user: \(user?.email ?? "")")
        } else {
            errorMessage = failure?.message
            print("Profile update failed: \(failure?.message ?? "")")
        }
        loading = false
        return failure
    }

    // MARK: - Utility Methods
    func clearError() {
        self.errorMessage = nil
    }
}
