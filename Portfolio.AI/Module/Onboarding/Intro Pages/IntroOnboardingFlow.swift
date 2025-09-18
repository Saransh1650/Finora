import SwiftUI

struct IntroOnboardingFlow: View {
    @State private var page: Int = 0
    var onFinish: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Page content
            ZStack {
                switch page {
                case 0:
                    IntroScanPage(nextAction: {
                        withAnimation(.easeInOut) { page = 1 }
                    })
                case 1:
                    IntroAnalysePage(nextAction: {
                        withAnimation(.easeInOut) { page = 2 }
                    })
                case 2:
                    IntroAdvicePage(nextAction: {
                        withAnimation(.easeInOut) {
                            onFinish?()
                        }
                    })
                default:
                    IntroScanPage(nextAction: {
                        withAnimation(.easeInOut) { page = 1 }
                    })
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(
                            index == page
                                ? AppColors.selected : AppColors.divider
                        )
                        .frame(
                            width: index == page ? 12 : 8,
                            height: index == page ? 12 : 8
                        )
                        .scaleEffect(index == page ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.25), value: page)
                }
            }
            .padding(.vertical, 16)

        }
        .background(AppColors.pureBackground)
    }
}

#Preview {
    IntroOnboardingFlow()
}
