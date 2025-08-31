//
//  app_button.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import SwiftUI

struct AppButton: View {
    let title: String
    let action: () -> Void
    var foregroundColor: Color = .white
    var backgroundColor: Color = .blue

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding()
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
        }
        .background(backgroundColor)
        .cornerRadius(16)
        
    }

}

#Preview {
    AppButton(title: "Click Me", action: {})
}
