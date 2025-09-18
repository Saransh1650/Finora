//
//  PortfolioPage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import SwiftUI

struct PortfolioPage: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State var addStock = false
    var body: some View {
        ZStack {
            AppColors.pureBackground.ignoresSafeArea()

            if portfolioManager.stocks.isEmpty {
                EmptyPortfolioView()
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        PortfolioSummaryCard(stocks: portfolioManager.stocks)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        LazyVStack(spacing: 12) {
                            ForEach(portfolioManager.stocks, id: \.id) {
                                stock in
                                StockCard(stock: stock)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            if let index = portfolioManager
                                                .stocks.firstIndex(of: stock)
                                            {
                                                Task {
                                                    await portfolioManager
                                                        .removeStock(
                                                            at: IndexSet(
                                                                integer: index
                                                            )
                                                        )
                                                }
                                            }
                                        } label: {
                                            Label(
                                                "Remove",
                                                systemImage: "trash"
                                            )
                                        }

                                        Button {
                                            Task {
                                                await portfolioManager
                                                    .updateStock(stock)
                                            }
                                        } label: {
                                            Label(
                                                "Update Stock",
                                                systemImage: "pencil"
                                            )
                                        }
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            if let index = portfolioManager
                                                .stocks.firstIndex(of: stock)
                                            {
                                                Task {
                                                    await portfolioManager
                                                        .removeStock(
                                                            at: IndexSet(
                                                                integer: index
                                                            )
                                                        )
                                                }
                                            }
                                        } label: {
                                            Label(
                                                "Remove",
                                                systemImage: "trash"
                                            )
                                        }
                                        .tint(.red)

                                        Button {
                                            Task {
                                                await portfolioManager
                                                    .updateStock(stock)
                                            }
                                        } label: {
                                            Label(
                                                "Update",
                                                systemImage: "pencil"
                                            )
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
            }
        }
        .navigationTitle(Text("Portfolio"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    addStock = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(AppColors.textPrimary)
                }
                .fullScreenCover(isPresented: $addStock) {
                    AddStockDialog()
                        .background(ClearBackgroundView())
                }

            }
        }
    }
}

#Preview {
    NavigationStack {
        PortfolioPage()
    }
}
