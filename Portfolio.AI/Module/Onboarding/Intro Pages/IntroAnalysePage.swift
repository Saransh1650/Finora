//
//  IntroAnalysePage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 3/9/25.
//

import SwiftUI

struct IntroAnalysePage: View {
    // add optional next action so a container can navigate
    var nextAction: (() -> Void)? = nil
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            AppColors.pureBackground.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Icon with animation
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.selected)
                    .padding()
                    .background(
                        Circle()
                            .fill(AppColors.background)
                            .shadow(
                                color: AppColors.divider.opacity(0.5),
                                radius: 10
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                AppColors.selected.opacity(0.2),
                                lineWidth: 2
                            )
                    )
                    .rotationEffect(Angle(degrees: isAnimating ? 5 : -5))
                    .animation(
                        .easeInOut(duration: 3).repeatForever(
                            autoreverses: true
                        ),
                        value: isAnimating
                    )
                    .onAppear {
                        isAnimating = true
                    }

                // Content
                VStack(alignment: .center, spacing: 16) {
                    Text("Let AI Analyse It")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(
                        "Our AI will automatically analyse your uploaded portfolio and extract key insights."
                    )
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal)

                Spacer()

                // Bottom Next button
                if let next = nextAction {
                    Button(action: { next() }) {
                        Text("Next")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.selected)
                            .foregroundColor(AppColors.background)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

            }
            .padding()
        }
    }
}

#Preview {
    IntroAnalysePage()
}
