//
//  PortfolioPage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import SwiftUI

struct PortfolioPage: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var showMethodSelection = false
    @State private var showManualDialog = false
    @State private var showOCRDialog = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.pureBackground.ignoresSafeArea()

                if portfolioManager.stocks.isEmpty {
                    EmptyPortfolioView(
                        showManualDialog: $showManualDialog,
                        showOCRDialog: $showOCRDialog
                    )
                } else {
                    VStack(spacing: 0) {
                        ScrollView {
                            PortfolioSummaryCard(
                                stocks: portfolioManager.stocks
                            )
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
                                                    .stocks.firstIndex(
                                                        of: stock
                                                    )
                                                {
                                                    Task {
                                                        await portfolioManager
                                                            .removeStock(
                                                                at: IndexSet(
                                                                    integer:
                                                                        index
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
                                            //TODO: implement later
                                            //                                            Button {
                                            //                                                Task {
                                            //                                                    await portfolioManager
                                            //                                                        .updateStock(stock)
                                            //                                                }
                                            //                                            } label: {
                                            //                                                Label(
                                            //                                                    "Update Stock",
                                            //                                                    systemImage: "pencil"
                                            //                                                )
                                            //                                            }
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                if let index = portfolioManager
                                                    .stocks.firstIndex(
                                                        of: stock
                                                    )
                                                {
                                                    Task {
                                                        await portfolioManager
                                                            .removeStock(
                                                                at: IndexSet(
                                                                    integer:
                                                                        index
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

                            //Info text
                            HStack {
                                Image(systemName: "info.circle")

                                Text(
                                    "Hold any stock to delete or update its data."
                                )
                            }
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
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
                        showMethodSelection = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .fullScreenCover(isPresented: $showMethodSelection) {
                AddStockMethodDialog { method in
                    switch method {
                    case .ocr:
                        showOCRDialog = true
                    case .manual:
                        showManualDialog = true
                    }
                }
                .background(ClearBackgroundView())
            }
            .fullScreenCover(isPresented: $showManualDialog) {
                AddStockDialog()
                    .background(ClearBackgroundView())
            }
            .fullScreenCover(isPresented: $showOCRDialog) {
                OCRStockSelectionDialog()
                    .background(ClearBackgroundView())
            }
        }
    }
}

#Preview {
    NavigationStack {
        PortfolioPage()
    }
}
