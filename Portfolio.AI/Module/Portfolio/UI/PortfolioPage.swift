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
        List {
            ForEach(portfolioManager.stocks, id: \.id) { stock in
                StockCard(stock: stock)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(content: {
                        Button(role: .destructive) {
                            if let index = portfolioManager.stocks.firstIndex(
                                of: stock
                            ) {
                                Task {
                                    await portfolioManager.removeStock(
                                        at: IndexSet(integer: index)
                                    )
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
                            Label("Update", systemImage: "slider.vertical.3")
                        }
                    })
                    .contextMenu {
                        Button(role: .destructive) {
                            if let index = portfolioManager.stocks.firstIndex(
                                of: stock
                            ) {
                                Task {
                                    await portfolioManager.removeStock(
                                        at: IndexSet(integer: index)
                                    )
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
            }
            .onDelete { indexSet in
                Task {
                    await portfolioManager.removeStock(at: indexSet)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Body
    var body: some View {
        ZStack {

            if portfolioManager.stocks.isEmpty {
                EmptyPortfolioView()
            } else {
                VStack(spacing: 0) {
                    portfolioList
                }
            }
        }
        .navigationTitle("Portfolio")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                AddStockButton()
            }
        }
    }
}

#Preview {
    NavigationStack {
        PortfolioPage()
    }
}
