//
//  PrivacyPolicyPage.swift
//  Finora
//
//  Created by Saransh Singhal on 27/9/25.
//

import SwiftUI

struct PrivacyPolicyPage: View {
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

                // Introduction
                PolicySection(
                    title: "Introduction",
                    content:
                        "Welcome to Finora (\"we,\" \"our,\" or \"the App\"). This Privacy Policy explains how we collect, use, and protect your information when you use our portfolio analysis application. By using Finora, you agree to the collection and use of information in accordance with this policy."
                )

                // Disclaimer Section - Most Important
                PolicySection(
                    title: "Important Disclaimer",
                    content: """
                        **USER RESPONSIBILITY AND LIABILITY DISCLAIMER**

                        Finora is provided for informational purposes only. By using this application, you acknowledge and agree that:

                        • **YOU ARE SOLELY RESPONSIBLE** for all investment decisions and actions taken based on information provided by this app
                        • **NO LIABILITY FOR LOSSES OR GAINS**: We do not accept any liability for financial losses, gains, or any other consequences resulting from your use of this application
                        • **NOT FINANCIAL ADVICE**: The analysis, recommendations, and information provided are not professional financial advice and should not be treated as such
                        • **USER DISCRETION**: All investment decisions are made at your own risk and discretion
                        • **NO GUARANTEES**: We make no representations or warranties about the accuracy, completeness, or reliability of any information provided
                        • **CONSULT PROFESSIONALS**: You should consult with qualified financial advisors before making any investment decisions
                        """,
                    isHighlight: true
                )

                // Information We Collect
                PolicySection(
                    title: "Information We Collect",
                    content: """
                        **Personal Information:**
                        • Account registration details (name, email address)
                        • Portfolio data you input (stock symbols, quantities, purchase prices)
                        • Usage analytics and app interaction data

                        **Device Information:**
                        • Device identifiers and operating system information
                        • App version and crash reports
                        • General location data (country/region level only)
                        """
                )

                // How We Use Your Information
                PolicySection(
                    title: "How We Use Your Information",
                    content: """
                        We use the collected information to:
                        • Provide portfolio analysis and recommendations
                        • Improve app functionality and user experience
                        • Send important updates and notifications
                        • Provide customer support
                        • Analyze usage patterns to enhance our services
                        """
                )

                // Data Storage and Security
                PolicySection(
                    title: "Data Storage and Security",
                    content: """
                        • Your data is stored securely using industry-standard encryption
                        • We implement appropriate technical and organizational measures to protect your information
                        • Portfolio data is stored locally on your device and in our secure cloud servers
                        • We regularly review and update our security practices
                        """
                )

                // Data Sharing
                PolicySection(
                    title: "Data Sharing",
                    content: """
                        We DO NOT sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:
                        • With your explicit consent
                        • To comply with legal obligations
                        • To protect our rights and safety
                        • With service providers who assist in app functionality (under strict confidentiality agreements)
                        """
                )

                // Investment Risks
                PolicySection(
                    title: "Investment Risk Acknowledgment",
                    content: """
                        **IMPORTANT RISK DISCLOSURE:**

                        • **Market Risk**: All investments carry inherent risks, and past performance does not guarantee future results
                        • **Volatility**: Portfolio values can fluctuate significantly and may result in substantial losses
                        • **No Guarantees**: Finora provides analysis tools but cannot guarantee investment outcomes
                        • **Individual Responsibility**: Each user must evaluate their own financial situation and risk tolerance
                        • **Professional Advice**: Consider consulting with licensed financial advisors for personalized investment guidance
                        """,
                    isHighlight: true
                )

                // User Rights
                PolicySection(
                    title: "Your Rights",
                    content: """
                        You have the right to:
                        • Access your personal data
                        • Correct inaccurate information
                        • Delete your account and associated data
                        • Export your portfolio data
                        • Withdraw consent for data processing

                        To exercise these rights, contact us at privacy@portfolioai.com
                        """
                )

                // Third-Party Services
                PolicySection(
                    title: "Third-Party Services",
                    content: """
                        Finora may integrate with third-party services for:
                        • Stock market data providers
                        • Analytics and crash reporting services
                        • Authentication services

                        These services have their own privacy policies, and we encourage you to review them.
                        """
                )

                // Changes to Privacy Policy
                PolicySection(
                    title: "Changes to This Privacy Policy",
                    content: """
                        We may update this Privacy Policy from time to time. We will notify you of any changes by:
                        • Posting the new Privacy Policy in the app
                        • Sending you a notification
                        • Updating the "Last Updated" date

                        Continued use of the app after changes constitutes acceptance of the updated policy.
                        """
                )

                // Contact Information
                PolicySection(
                    title: "Contact Us",
                    content: """
                        If you have any questions about this Privacy Policy, please contact us:

                        **Email:** singhalsaransh40@gmail.com

                        We will respond to your inquiries within 30 days.
                        """
                )

                // Final Disclaimer
                VStack(alignment: .leading, spacing: 12) {
                    Text("Final Disclaimer")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)

                    Text(
                        "BY USING FINORA, YOU ACKNOWLEDGE THAT YOU HAVE READ, UNDERSTOOD, AND AGREE TO BE BOUND BY THIS PRIVACY POLICY AND ALL DISCLAIMERS CONTAINED HEREIN. YOU UNDERSTAND THAT INVESTMENT INVOLVES RISK AND THAT YOU ARE SOLELY RESPONSIBLE FOR YOUR INVESTMENT DECISIONS."
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
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PolicySection: View {
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
                        ? Color.orange.opacity(0.05) : AppColors.pureBackground
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
                        ? Color.orange.opacity(0.3)
                        : AppColors.border.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyPage()
    }
}
