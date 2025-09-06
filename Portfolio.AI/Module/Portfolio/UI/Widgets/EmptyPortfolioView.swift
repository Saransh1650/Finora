//
//  EmptyPortfolioView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import SwiftUI

struct EmptyPortfolioView: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 70))
                .foregroundColor(Color.gray.opacity(0.5))
            
            Text("Your Portfolio is Empty")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.foreground)
            
            Text("Start adding stocks to track your investments")
                .font(.body)
                .foregroundColor(AppColors.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            AddStockButton()
                .padding(.top, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyPortfolioView()
}
