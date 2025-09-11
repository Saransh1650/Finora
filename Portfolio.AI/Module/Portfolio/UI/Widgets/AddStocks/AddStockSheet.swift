//
//  AddStockSheet.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import SwiftUI

struct AddStockSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var portfolioManager: PortfolioManager
    
    @State private var stockSymbol: String = ""
    @State private var stockName: String = ""
    @State private var sector: String = ""
    @State private var avgPrice: String = ""
    @State private var quantity: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Predefined sectors for selection
    private let sectors = ["Technology", "Healthcare", "Finance", "Consumer Goods",
                           "Energy", "Utilities", "Real Estate", "Automotive", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Stock Information")) {
                    TextField("Symbol (e.g. AAPL)", text: $stockSymbol)
                        .autocapitalization(.allCharacters)
                        .tint(.blue)
                    
                    TextField("Company Name", text: $stockName)
                        .tint(.blue)
                    
                    Picker("Sector", selection: $sector) {
                        ForEach(sectors, id: \.self) { sector in
                            Text(sector).tag(sector)
                        }
                    }
                }
                
                Section(header: Text("Investment Details")) {
                    TextField("Average Price", text: $avgPrice)
                        .keyboardType(.decimalPad)
                        .tint(.blue)
                    
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                        .tint(.blue)
                    
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: addStock) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Add to Portfolio")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .disabled(isLoading || !isFormValid)
                }
            }
            .navigationTitle("Add Stock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !stockSymbol.isEmpty &&
        !stockName.isEmpty &&
        !sector.isEmpty &&
        !avgPrice.isEmpty &&
        Double(avgPrice) != nil &&
        !quantity.isEmpty &&
        Double(quantity) != nil
    }
    
    private func addStock() {
        guard isFormValid else { return }
        
        guard let price = Double(avgPrice),
              let qty = Double(quantity) else {
            errorMessage = "Please enter valid numbers for price and quantity"
            return
        }
        
        // Safely unwrap user id
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else {
            errorMessage = "User not authenticated. Please log in again."
            return
        }
        
        isLoading = true
        
        // In a real app, we would fetch the latest price from an API
        // For now, we'll simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)  {
            // Create the new stock
            let newStock = StockModel(
                userId: userId.uuidString,
                name: stockName,
                symbol: stockSymbol.uppercased(),
                portfolioPercentage: 0.0,
                sector: sector,
                profitLossPercentage: 0.0,
                sectorRank: 1,
                avgPrice: price,
                lastTradingPrice: price
            )
            
            // Add to portfolio
            Task{
                await portfolioManager.addStock([newStock])
            }
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    AddStockSheet()
}
