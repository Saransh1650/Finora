//
//  UserInfoSideBar.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 31/8/25.
//

import SwiftUI

struct UserInfoSideBar: View {
    var supabase = SupabaseManager.shared
    @Binding var isOpen: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                
               
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(supabase.client.auth.currentUser?.email ?? "Guest User")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
}

#Preview {
    UserInfoSideBar(isOpen: .constant(true))
}
