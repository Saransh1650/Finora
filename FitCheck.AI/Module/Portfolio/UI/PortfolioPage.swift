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
        ZStack {
            AppColors.pureBackground
                .ignoresSafeArea()
            
            List {
                ForEach(stocks) { stock in
                    StockCard(stock: stock)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Portfolio")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    PortfolioPage()
}
