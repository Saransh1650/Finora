//
//  PortfolioPage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import SwiftUI

struct PortfolioPage: View {
    @EnvironmentObject var portfolioManager: PortfolioManager

    // MARK: - Portfolio List
    private var portfolioList: some View {
        ScrollView {
            PortfolioSummaryCard(stocks: portfolioManager.stocks)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 4)
            LazyVStack(spacing: 12) {
                ForEach(portfolioManager.stocks, id: \.id) { stock in
                    StockCard(stock: stock)
                        .contextMenu {
                            Button(role: .destructive) {
                                if let index = portfolioManager.stocks.firstIndex(of: stock) {
                                    Task {
                                        await portfolioManager.removeStock(at: IndexSet(integer: index))
                                    }
                                }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }

                            Button {
                                Task {
                                    await portfolioManager.updateStock(stock)
                                }
                            } label: {
                                Label("Update Stock", systemImage: "pencil")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                if let index = portfolioManager.stocks.firstIndex(of: stock) {
                                    Task {
                                        await portfolioManager.removeStock(at: IndexSet(integer: index))
                                    }
                                }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                            .tint(.red)

                            Button {
                                Task {
                                    await portfolioManager.updateStock(stock)
                                }
                            } label: {
                                Label("Update", systemImage: "pencil")
                            }
                            .tint(AppColors.selected)
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(AppColors.pureBackground)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            AppColors.pureBackground.ignoresSafeArea()
            
            if portfolioManager.stocks.isEmpty {
                EmptyPortfolioView()
            } else {
                VStack(spacing: 0) {
                    // Portfolio Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Stocks")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("\(portfolioManager.stocks.count) holdings")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        AddStockButton()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    
                    portfolioList
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        PortfolioPage()
    }
}
