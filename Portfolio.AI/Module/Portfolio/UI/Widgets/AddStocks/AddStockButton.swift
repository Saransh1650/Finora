//
//  AddStockButton.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import SwiftUI

struct AddStockButton: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var showingAddSheet = false
    
    var body: some View {
        Button(action: {
            showingAddSheet = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Add Stock")
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.blue)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddStockSheet()
        }
    }
}

#Preview {
    AddStockButton()
}
