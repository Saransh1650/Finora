//
//  CustomNavBar.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 4/9/25.
//

import SwiftUI

struct CustomNavBar: View {
    @Binding var selectedTab: TabItem
    @State private var animatingTab: TabItem? = nil
    
    var body: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { tab in
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                        animatingTab = tab
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        animatingTab = nil
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .scaleEffect(animatingTab == tab ? 1.3 : (selectedTab == tab ? 1.1 : 1.0))
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animatingTab)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
                        
                        Text(tab.title)
                            .font(.caption2)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                    }
                    .foregroundColor(selectedTab == tab ? AppColors.selected : AppColors.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .background(
            AppColors.pureBackground
                .ignoresSafeArea(edges: .bottom)
        )
    }
}



#Preview {
    CustomNavBar(selectedTab: .constant(.home))
}
