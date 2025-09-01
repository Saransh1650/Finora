//
//  AuthRepoProtocol.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 1/9/25.
//

import Foundation
import AuthenticationServices
import Supabase

@MainActor
protocol AuthRepositoryProtocol {
    
    func signInWithApple(authorization: ASAuthorization) async 
    -> (User?, Failure?)
    func signInWithGoogle(idToken: String, accessToken: String) async
    -> (User?, Failure?)
    func signOut() async -> Failure?
    func getCurrentUser() async throws -> (User?, Failure?)
    func refreshSession() async throws -> (User?, Failure?)
    func updateUserProfile(fullName: String?, avatarUrl: String?) async
    -> (User?, Failure?)
    func deleteAccount() async -> Failure?
}
