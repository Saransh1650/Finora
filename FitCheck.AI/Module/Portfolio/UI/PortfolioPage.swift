//
//  PortfolioPage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import SwiftUI

struct PortfolioPage: View {
    var stocks: [StockModel] = StockModel.samples

    var body: some View {

        NavigationStack {
            ZStack {
                
                List {
                    ForEach(stocks) { stock in
                        StockCard(stock: stock)
                            .listRowSeparator(.automatic)
                            .listRowBackground(AppColors.background)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Portfolio")
        }
    }
}

#Preview {
    PortfolioPage()
}
