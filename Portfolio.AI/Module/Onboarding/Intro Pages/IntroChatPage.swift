import SwiftUI

struct IntroChatPage: View {
    var nextAction: (() -> Void)? = nil
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            AppColors.pureBackground.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Icon with animated glow using an overlay circle
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .padding()
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.selected)
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
                    Text("Chat with Your AI Advisor")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(
                        "Ask questions, get instant insights, and receive personalized financial advice from your AI assistant—anytime you need it."
                    )
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal)

                Spacer()

                // Bottom Done button
                if let next = nextAction {
                    Button(action: { next() }) {
                        Text("Done")
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
    IntroChatPage()
}
