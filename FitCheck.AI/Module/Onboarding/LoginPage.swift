//
//  LoginPage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 1/9/25.
//

import AuthenticationServices
import SwiftUI

struct LoginPage: View {
    @StateObject private var authManager = AuthManager(authRepo: AuthRepo())
    @State private var showingAlert = false

    var body: some View {
        ZStack {
            // Background
            AppColors.pureBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App Logo and Branding
                VStack(spacing: 20) {
                    // App Icon/Logo placeholder
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    // App Name
                    Text("FitCheck.AI")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.foreground)

                    // Tagline
                    Text("Your AI-powered fitness companion")
                        .font(.headline)
                        .foregroundColor(AppColors.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Login Section
                VStack(spacing: 24) {
                    // Welcome Text
                    VStack(spacing: 8) {
                        Text("Welcome Back!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.foreground)

                        Text("Sign in to continue your fitness journey")
                            .font(.body)
                            .foregroundColor(AppColors.tertiary)
                            .multilineTextAlignment(.center)
                    }

                    // Login Buttons
                    VStack(spacing: 16) {
                        // Apple Sign In Button
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                Task {
                                    await handleAppleSignIn(result: result)
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(25)
                        .disabled(authManager.loading)

                        // Google Sign In Button
                        Button(action: {
                            Task {
                                await handleGoogleSignIn()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .medium))

                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [Color.red, Color.orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                        }
                        .disabled(authManager.loading)
                        .opacity(authManager.loading ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 40)
                }

                Spacer()

                // Terms and Privacy
                VStack(spacing: 8) {
                    Text("By continuing, you agree to our")
                        .font(.caption)
                        .foregroundColor(AppColors.tertiary)

                    HStack(spacing: 4) {
                        Button("Terms of Service") {
                            // Handle terms action
                        }
                        .font(.caption)
                        .foregroundColor(.blue)

                        Text("and")
                            .font(.caption)
                            .foregroundColor(AppColors.tertiary)

                        Button("Privacy Policy") {
                            // Handle privacy action
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 40)
            }

            // Loading Overlay
            if authManager.loading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
        .alert("Authentication Error", isPresented: $showingAlert) {
            Button("OK") {
                authManager.clearError()
            }
        } message: {
            Text(authManager.errorMessage ?? "An unknown error occurred")
        }
        .onChange(of: authManager.errorMessage) { _, errorMessage in
            if errorMessage != nil {
                showingAlert = true
            }
        }
    }

    // MARK: - Authentication Methods

    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) async
    {
        switch result {
        case .success(let authorization):
            let failure = await authManager.signInWithApple(
                authorization: authorization
            )
            if failure == nil {
                // Navigate to main app or handle success
                print("Apple Sign In successful!")
            }

        case .failure(let error):
            print("Apple Sign In failed: \(error.localizedDescription)")
        // Error will be handled by the AuthManager
        }
    }

    private func handleGoogleSignIn() async {
        // TODO: Implement Google Sign In SDK
        // For now, simulate Google Sign In with mock tokens
        let failure = await authManager.signInWithGoogle(
            idToken: "mock_id_token",
            accessToken: "mock_access_token"
        )
        if failure == nil {
            // Navigate to main app or handle success
            print("Google Sign In successful!")
        }
    }
}

#Preview {
    LoginPage()
}
