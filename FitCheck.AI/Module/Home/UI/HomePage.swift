//
//  HomePage.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct HomePage: View {
    @State private var isDrawerOpen = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main Content
                VStack(spacing: 0) {
                    ScrollView {
                        
                    }
                    .background(AppColors.pureBackground)
                    Spacer()
                    Spacer()
                }
                
                // Sidebar with overlay
                if isDrawerOpen {
                    
                    // Background overlay
                    AppColors.textPrimary.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isDrawerOpen = false
                            }
                        }
                        .zIndex(1)
                    
                    // Drawer content
                    HStack {
                        SideAppDrawer(isOpen: $isDrawerOpen)
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                    .zIndex(2)
                }
            }
            .background(AppColors.pureBackground)
            .navigationTitle("Welcome")
            .toolbarVisibility(
                isDrawerOpen ? .hidden : .visible,
                for: .navigationBar
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isDrawerOpen.toggle()
                        }
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(AppColors.selected)
                            .font(.system(size: 24))
                            
                            
                    }
                }
            }
        }
    }
}

#Preview {
    HomePage()
}
