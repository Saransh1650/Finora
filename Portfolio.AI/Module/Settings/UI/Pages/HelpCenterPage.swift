//
//  HelpCenterPage.swift
//  Finora
//
//  Created by Saransh Singhal on 30/9/25.
//

import SwiftUI

struct HelpCenterPage: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            AppColors.pureBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, ) {
                            Text("Find answers to common questions")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.textSecondary)
                            
                            TextField("Search help articles...", text: $searchText)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(12)
                        .background(AppColors.background)
                        .cornerRadius(12)
                        
                        // Quick Actions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Actions")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(spacing: 12) {
                                QuickActionCard(
                                    icon: "envelope.fill",
                                    title: "Email Support",
                                    description: "Get help from our support team",
                                    action: {
                                        if let url = URL(string: "mailto:singhalsaransh40@gmail.com") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )
                                
                                QuickActionCard(
                                    icon: "heart.fill",
                                    title: "Send Feedback",
                                    description: "Share your ideas with us",
                                    action: {
                                        if let url = URL(string: "mailto:singhalsaransh40@gmail.com?subject=Finora%20Feedback") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )
                            }
                        }
                        
                        // FAQ Sections
                        FAQSection(
                            title: "Getting Started",
                            items: [
                                FAQItem(
                                    question: "How do I add stocks to my portfolio?",
                                    answer: "Navigate to the Portfolio tab and tap the '+' button. Enter the stock symbol, quantity, and purchase price. The app will automatically fetch current market data."
                                ),
                                FAQItem(
                                    question: "How does portfolio analysis work?",
                                    answer: "Our AI analyzes your portfolio composition, sector allocation, risk exposure, and performance metrics. You need at least 2 stocks to generate an analysis."
                                ),
                                FAQItem(
                                    question: "What is the AI Chat feature?",
                                    answer: "The AI Chat provides personalized investment insights based on your portfolio. Ask questions about diversification, risk management, or specific holdings."
                                )
                            ]
                        )
                        
                        FAQSection(
                            title: "Portfolio Management",
                            items: [
                                FAQItem(
                                    question: "How often is market data updated?",
                                    answer: "Market data is updated in real-time during trading hours. Portfolio valuations are refreshed automatically when you open the app."
                                ),
                                FAQItem(
                                    question: "Can I track multiple portfolios?",
                                    answer: "Currently, the app supports one main portfolio per account. You can manage multiple stocks within your portfolio."
                                ),
                                FAQItem(
                                    question: "How do I edit or remove stocks?",
                                    answer: "Swipe left on any stock card to reveal edit and delete options. You can also long-press for a context menu."
                                )
                            ]
                        )
                        
                        FAQSection(
                            title: "Account & Privacy",
                            items: [
                                FAQItem(
                                    question: "Is my portfolio data secure?",
                                    answer: "Yes, all your data is encrypted and stored securely. We use industry-standard security measures to protect your information."
                                ),
                                FAQItem(
                                    question: "How do I delete my account?",
                                    answer: "Go to Settings > Scroll Down > Delete Account. This action is permanent and will remove all your data from our servers."
                                ),
                                FAQItem(
                                    question: "What data do you collect?",
                                    answer: "We do not collect any of your data, once you delete your account, we clear your portfolio data, analysis and chat."
                                )
                            ]
                        )
                        
                        FAQSection(
                            title: "AI & Recommendations",
                            items: [
                                FAQItem(
                                    question: "Are AI recommendations financial advice?",
                                    answer: "No. The AI provides educational insights only. Always consult qualified financial advisors before making investment decisions. You are solely responsible for your investment choices."
                                ),
                                FAQItem(
                                    question: "How accurate are the AI predictions?",
                                    answer: "AI analysis is based on historical data and current market conditions. However, markets are unpredictable and past performance doesn't guarantee future results."
                                ),
                                FAQItem(
                                    question: "Can I trust the rebalancing suggestions?",
                                    answer: "Rebalancing suggestions are educational tools to help you understand portfolio optimization. Always do your own research and consider your risk tolerance."
                                )
                            ]
                        )
                        
                        // Contact Support Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Still need help?")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Can't find what you're looking for? Our support team is here to help!")
                                .font(.system(size: 15))
                                .foregroundColor(AppColors.textSecondary)
                            
                            AppButton(title: "Contact Support", action: {
                                if let url = URL(string: "mailto:singhalsaransh40@gmail.com?subject=Finora%20Support%20Request") {
                                    UIApplication.shared.open(url)
                                }
                            }, icon: "envelope.fill", hapticFeedback: .medium)
                        }
                        .padding()
                        .background(AppColors.background)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.selected)
                    .frame(width: 40, height: 40)
                    .background(AppColors.selected.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding()
            .background(AppColors.background)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - FAQ Section
struct FAQSection: View {
    let title: String
    let items: [FAQItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 8) {
                ForEach(items) { item in
                    FAQItemView(item: item)
                }
            }
        }
    }
}

// MARK: - FAQ Item
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQItemView: View {
    let item: FAQItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(item.question)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(item.answer)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppColors.background)
        .cornerRadius(12)
    }
}

#Preview {
    HelpCenterPage()
}
