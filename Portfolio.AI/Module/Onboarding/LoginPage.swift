//
//  LoginPage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 1/9/25.
//

import AuthenticationServices
import SwiftUI

struct LoginPage: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingAlert = false
    @State private var navigateToHome = false
    @State var showTermsAndCondition = false
    @State var showPrivacyPolicy = false

    var body: some View {

        NavigationStack {
            ZStack {
                AppColors.pureBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // App Logo and Branding
                    VStack(spacing: 20) {
                        // App Icon/Logo placeholder
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.background,
                                        AppColors.pureBackground.opacity(0.8),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                            )
                        // App Name
                        Text("Finora")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)

                        // Tagline
                        Text("Your AI-powered Finance Companion")
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

                            Text("Sign in to continue your finance journey")
                                .font(.body)
                                .foregroundColor(AppColors.tertiary)
                                .multilineTextAlignment(.center)
                        }

                        // Login Buttons
                        VStack(spacing: 16) {
                            AppButton(
                                title: "Sign In with Google",
                                action: {
                                    Task {
                                        await handleGoogleSignIn()
                                    }
                                },
                                image: "Google"
                            )
                        }
                        .padding(.horizontal, 40)
                    }

                    // Terms and Privacy
                    VStack(spacing: 8) {
                        Text("By continuing, you agree to our")
                            .font(.caption)
                            .foregroundColor(AppColors.tertiary)

                        HStack(spacing: 4) {
                            Button("Terms of Service") {
                                showTermsAndCondition = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)

                            Text("and")
                                .font(.caption)
                                .foregroundColor(AppColors.tertiary)

                            Button("Privacy Policy") {
                                showPrivacyPolicy = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }

                // Loading Overlay
                if authManager.loading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
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
            .navigationDestination(isPresented: $showTermsAndCondition) {
                TermsOfServicePage()
            }
            .navigationDestination(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyPage()
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
        if let windowScene = UIApplication.shared.connectedScenes.first
            as? UIWindowScene,
            let rootViewController = windowScene.windows.first?
                .rootViewController
        {
            let failure = await authManager.signInWithGoogle(
                presentingController: rootViewController
            )
            if failure == nil {
                navigateToHome = true
            }
        } else {
            navigateToHome = false
            showingAlert = true
        }
    }
}

#Preview {
    LoginPage()
        .environmentObject(AuthManager())
}
