//
//  TermsOfServicePage.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 27/9/25.
//

import SwiftUI

struct TermsOfServicePage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {

                    Text("Effective Date: September 27, 2025")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)

                    Text("Last Updated: September 27, 2025")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.bottom, 8)

                // Acceptance of Terms
                TermsSection(
                    title: "Acceptance of Terms",
                    content: """
                        By downloading, installing, or using Portfolio.AI ("the App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the App.

                        These Terms constitute a legally binding agreement between you and Portfolio.AI.
                        """
                )

                // Critical Disclaimer - Most Important
                TermsSection(
                    title: "CRITICAL LIABILITY DISCLAIMER",
                    content: """
                        **READ THIS SECTION CAREFULLY - IT LIMITS OUR LIABILITY**

                        • **NO LIABILITY FOR FINANCIAL LOSSES**: Portfolio.AI and its developers SHALL NOT be liable for any financial losses, investment losses, or any damages arising from your use of this application

                        • **USER SOLE RESPONSIBILITY**: You are SOLELY responsible for all investment decisions and actions taken. The App provides tools and information only - final decisions are entirely yours

                        • **NOT FINANCIAL ADVICE**: Nothing in this App constitutes professional financial, investment, or tax advice. All content is for informational purposes only

                        • **NO GUARANTEES**: We make no warranties or guarantees about investment outcomes, accuracy of data, or app performance

                        • **USE AT YOUR OWN RISK**: Your use of the App is at your own risk and discretion
                        """,
                    isHighlight: true
                )

                // License to Use
                TermsSection(
                    title: "License to Use",
                    content: """
                        Portfolio.AI grants you a limited, non-exclusive, non-transferable license to use the App for personal, non-commercial purposes only.

                        You may NOT:
                        • Copy, modify, or distribute the App
                        • Reverse engineer or attempt to extract source code
                        • Use the App for commercial purposes without permission
                        • Share your account credentials with others
                        """
                )

                // User Obligations
                TermsSection(
                    title: "User Obligations",
                    content: """
                        By using Portfolio.AI, you agree to:
                        • Provide accurate information when requested
                        • Use the App in compliance with all applicable laws
                        • Not attempt to harm or disrupt the App's functionality
                        • Not use the App for illegal or unauthorized purposes
                        • Take full responsibility for your investment decisions
                        • Consult with qualified professionals before making financial decisions
                        """
                )

                // Investment Risks Acknowledgment
                TermsSection(
                    title: "Investment Risks Acknowledgment",
                    content: """
                        **BY USING THIS APP, YOU ACKNOWLEDGE:**

                        • All investments involve risk of loss
                        • Past performance does not guarantee future results
                        • Market conditions can change rapidly
                        • You may lose some or all of your invested capital
                        • The App's analysis and recommendations are not guarantees
                        • You should diversify your investments and never invest more than you can afford to lose
                        """,
                    isHighlight: true
                )

                // Data and Privacy
                TermsSection(
                    title: "Data and Privacy",
                    content: """
                        Your use of the App is also governed by our Privacy Policy. By using the App, you consent to:
                        • Collection and use of your data as described in our Privacy Policy
                        • Storage of your portfolio information
                        • Analytics and performance monitoring

                        You are responsible for keeping your account information secure.
                        """
                )

                // Intellectual Property
                TermsSection(
                    title: "Intellectual Property",
                    content: """
                        Portfolio.AI and all related content, features, and functionality are owned by the developers and are protected by copyright, trademark, and other intellectual property laws.

                        You retain ownership of your personal data and portfolio information.
                        """
                )

                // Service Availability
                TermsSection(
                    title: "Service Availability",
                    content: """
                        We strive to provide reliable service, but we cannot guarantee:
                        • Uninterrupted access to the App
                        • Error-free operation
                        • Compatibility with all devices
                        • Availability of all features at all times

                        We may modify, suspend, or discontinue any part of the service at any time.
                        """
                )

                // Prohibited Uses
                TermsSection(
                    title: "Prohibited Uses",
                    content: """
                        You may NOT use Portfolio.AI to:
                        • Provide financial advice to others without proper licensing
                        • Make automated trading decisions without human oversight
                        • Violate any applicable laws or regulations
                        • Interfere with other users' experience
                        • Attempt to hack or compromise the App's security
                        """
                )

                // Limitation of Liability
                TermsSection(
                    title: "Limitation of Liability",
                    content: """
                        **IMPORTANT LEGAL PROTECTION:**

                        TO THE FULLEST EXTENT PERMITTED BY LAW, PORTFOLIO.AI SHALL NOT BE LIABLE FOR:
                        • Any indirect, incidental, special, or consequential damages
                        • Loss of profits, data, or business opportunities
                        • Financial losses from investment decisions
                        • Damages exceeding the amount paid for the App (if any)

                        This limitation applies even if we have been advised of the possibility of such damages.
                        """,
                    isHighlight: true
                )

                // Modifications to Terms
                TermsSection(
                    title: "Modifications to Terms",
                    content: """
                        We reserve the right to modify these Terms at any time. When we make changes, we will:
                        • Update the "Last Updated" date
                        • Notify users through the App
                        • Post the new terms in the App

                        Continued use after changes constitutes acceptance of the modified Terms.
                        """
                )

                // Termination
                TermsSection(
                    title: "Termination",
                    content: """
                        Either party may terminate this agreement at any time:
                        • You may stop using the App and delete it from your device
                        • We may suspend or terminate your access for violation of these Terms
                        • Upon termination, you must cease all use of the App
                        """
                )

                // Contact Information
                TermsSection(
                    title: "Contact Information",
                    content: """
                        For questions about these Terms of Service:

                        **Email:** legal@portfolioai.com
                        **Support:** support@portfolioai.com

                        We will respond to your inquiries within 30 days.
                        """
                )

                // Final Acknowledgment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Final Acknowledgment")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)

                    Text(
                        "BY USING PORTFOLIO.AI, YOU ACKNOWLEDGE THAT YOU HAVE READ, UNDERSTOOD, AND AGREE TO BE BOUND BY THESE TERMS OF SERVICE. YOU UNDERSTAND THAT YOU ARE SOLELY RESPONSIBLE FOR YOUR INVESTMENT DECISIONS AND THAT THE APP DEVELOPERS ARE NOT LIABLE FOR ANY FINANCIAL LOSSES OR GAINS."
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        Color.red.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(AppColors.pureBackground)
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct TermsSection: View {
    let title: String
    let content: String
    let isHighlight: Bool

    init(title: String, content: String, isHighlight: Bool = false) {
        self.title = title
        self.content = content
        self.isHighlight = isHighlight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isHighlight ? .red : AppColors.textPrimary)

            Text(content)
                .font(.subheadline)
                .lineSpacing(4)
                .foregroundColor(
                    isHighlight
                        ? AppColors.textPrimary : AppColors.textSecondary
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isHighlight
                        ? Color.red.opacity(0.05) : AppColors.pureBackground
                )
                .shadow(
                    color: AppColors.textPrimary.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isHighlight
                        ? Color.red.opacity(0.3)
                        : AppColors.border.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    NavigationStack {
        TermsOfServicePage()
    }
}
