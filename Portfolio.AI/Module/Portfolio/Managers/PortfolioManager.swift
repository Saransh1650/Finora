//
//  PortfolioManager.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import Combine
import Foundation
import Supabase
import SwiftUI

@MainActor
class PortfolioManager: ObservableObject {
    @Published var stocks: [StockModel] = []
    @Published var isLoading: Bool = false

    init() {
        loadStocks()
    }

    private func loadStocks() {
        isLoading = true
        print("Loading stocks...")

        Task {
            do {
                let (stocks, error) = await PortfolioRepo.fetchStocks()
                if stocks != nil && error == nil {
                    self.stocks = stocks!
                } else if error != nil {
                    print(
                        "Error fetching stocks: \(String(describing: error?.message))"
                    )
                }
            }
        }
        isLoading = false
    }

    func addStock(_ newStocks: [StockModel]) async {
        for stock in newStocks {
            if let index = stocks.firstIndex(where: {
                $0.symbol == stock.symbol
            }) {
                stocks[index] = stock
            } else {
                stocks.append(stock)
            }
        }
        await PortfolioRepo.addStock(newStocks) { result in
            switch result {
            case .success():
                print("Stocks saved successfully to Supabase.")
            case .failure(let error):
                print("Failed to save stocks to Supabase: \(error)")

            }
        }
    }

    func removeStock(at indexSet: IndexSet) async {
        let idsToRemove = indexSet.map { stocks[$0].id.uuidString }
        stocks.remove(atOffsets: indexSet)
        await PortfolioRepo.deleteStocks(withId: idsToRemove) { result in
            switch result {
            case .success():
                print("Stocks removed successfully from Supabase.")
            case .failure(let error):
                print("Failed to remove stocks from Supabase: \(error)")

            }
        }

    }

    func deleteAllStocks() async {
        stocks.removeAll()
        await PortfolioRepo.deleteAllStocks { result in
            switch result {
            case .success():
                print("All stocks removed successfully from Supabase.")
            case .failure(let error):
                print("Failed to remove all stocks from Supabase: \(error)")

            }
        }
    }

    func updateStock(_ stock: StockModel) async {
        if let index = stocks.firstIndex(where: { $0.id == stock.id }) {
            stocks[index] = stock
            await PortfolioRepo.updateStock(stock) { result in
                switch result {
                case .success():
                    print("Stock updated successfully in Supabase.")
                case .failure(let error):
                    print("Failed to update stock in Supabase: \(error)")

                }
            }

        }
    }
}
