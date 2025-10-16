//
//  OCRSuggestedStockList.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/10/25.
//

import SwiftUI

struct OCRSuggestedStockList: View {
    var extractedStocks: [ExtractedStock]
    @Binding var selectedStocks: Set<String>
    @Binding var editableStocks: [String: EditableStockModel]
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(extractedStocks, id: \.symbol) { stock in
                    OCRStockRow(
                        stock: stock,
                        isSelected: selectedStocks.contains(
                            stock.symbol
                        ),
                        editableData: Binding(
                            get: {
                                editableStocks[stock.symbol]
                                    ?? EditableStockModel(
                                        totalInvestment: String(
                                            stock.totalInvestment
                                                ?? 0
                                        ),
                                        quantity: String(
                                            stock.quantity ?? 0
                                        )
                                    )
                            },
                            set: {
                                editableStocks[stock.symbol] = $0
                            }
                        ),
                        onToggle: {
                            if selectedStocks.contains(stock.symbol) {
                                selectedStocks.remove(stock.symbol)
                            } else {
                                selectedStocks.insert(stock.symbol)
                                // Initialize editable data if not exists
                                if editableStocks[stock.symbol]
                                    == nil
                                {
                                    editableStocks[stock.symbol] =
                                        EditableStockModel(
                                            totalInvestment: String(
                                                stock
                                                    .totalInvestment
                                                    ?? 0
                                            ),
                                            quantity: String(
                                                stock.quantity ?? 0
                                            )
                                        )
                                }
                            }
                        }
                    )
                }
            }
        }
        .frame(maxHeight: 300)
    }
}

#Preview {
    OCRSuggestedStockList(
        extractedStocks: [],
        selectedStocks: Binding.constant(
            Set<String>()
        ),
        editableStocks: Binding.constant(
            [String: EditableStockModel]())
    )
}
