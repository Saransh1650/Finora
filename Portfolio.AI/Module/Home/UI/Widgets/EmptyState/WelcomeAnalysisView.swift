//
//  WelcomeAnalysisView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 14/9/25.
//

import SwiftUI

struct WelcomeAnalysisView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Hero Section
                WelcomeHeroSection()

                // Features Section
                VStack(spacing: 16) {
                    FeatureCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Smart Analysis",
                        description:
                            "AI analyzes your portfolio performance and market trends"
                    )

                    FeatureCard(
                        icon: "shield.checkered",
                        title: "Risk Assessment",
                        description:
                            "Identify concentration risks and diversification opportunities"
                    )

                    FeatureCard(
                        icon: "lightbulb.fill",
                        title: "Actionable Insights",
                        description:
                            "Get clear recommendations for rebalancing and optimization"
                    )
                }
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    WelcomeAnalysisView()
}
