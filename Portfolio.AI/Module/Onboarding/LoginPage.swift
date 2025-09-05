//
//  LoginPage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 1/9/25.
//

import AuthenticationServices
import SwiftUI

struct LoginPage: View {
    @StateObject private var authManager = AuthManager()
    @State private var showingAlert = false
    
    var body: some View {
        ZStack {
            
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
                        SignInWithAppleButton { request in
                            request.requestedScopes = [.email, .fullName]
                        } onCompletion: { result in
                            Task {
                                do {
                                    guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential
                                    else {
                                        print("Failed to retrieve Apple ID credential.")
                                        return
                                    }
                                    guard let idToken = credential.identityToken
                                        .flatMap({ String(data: $0, encoding: .utf8) })
                                    else {
                                        print("Failed to retrieve ID token.")
                                        return
                                    }
                                    
                                    // Handle successful sign-in
                                    print("Apple Sign-In successful! ID Token: \(idToken)")
                                } catch {
                                    // Improved error handling with detailed logging
                                    print("Apple Sign-In failed with error: \(error.localizedDescription)")
                                    if let authError = error as? ASAuthorizationError {
                                        print("Error Code: \(authError.code.rawValue)")
                                        switch authError.code {
                                            case .canceled:
                                                print("Apple Sign-In was canceled by the user.")
                                            case .unknown:
                                                print("An unknown error occurred during Apple Sign-In. This may indicate a configuration issue.")
                                                print("Suggestions: Verify Apple Developer portal settings, ensure Sign in with Apple is enabled, and test on a real device.")
                                            case .invalidResponse:
                                                print("Invalid response received during Apple Sign-In. This may indicate a network issue or misconfiguration.")
                                            case .notHandled:
                                                print("Apple Sign-In request was not handled. Ensure the app is properly configured.")
                                            case .failed:
                                                print("Apple Sign-In failed: \(authError.localizedDescription). This may indicate a configuration issue.")
                                            case .notInteractive:
                                                print("Apple Sign-In is not interactive. Ensure the app is running on a real device.")
                                            case .matchedExcludedCredential:
                                                print("The credential matches an excluded credential. Check your app's configuration.")
                                            case .credentialImport:
                                                print("Credential import error during Apple Sign-In. Ensure Keychain Sharing is properly configured.")
                                            case .credentialExport:
                                                print("Credential export error during Apple Sign-In. Ensure Keychain Sharing is properly configured.")
                                            @unknown default:
                                                print("An unknown authorization error occurred. Default")
                                        }
                                    } else {
                                        print("Apple Sign-In failed with a non-authorization error: \(error)")
                                    }
                                }
                            }
                        }
                        .fixedSize()
                        
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
        let failure = await authManager.signInWithGoogle()
        if failure == nil {
            // Navigate to main app or handle success
            print("Google Sign In successful!")
        }
    }
}

#Preview {
    LoginPage()
}
