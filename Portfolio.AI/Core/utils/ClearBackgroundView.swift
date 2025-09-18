//
//  ClearbackgroundView.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 18/9/25.
//

import SwiftUI
import UIKit

struct ClearBackgroundView: UIViewRepresentable {
    var animationDuration: Double = 0.7
    var finalAlpha: CGFloat = 0.2
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            guard let backgroundView = view.superview?.superview else { return }
            
            
            backgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.0)
            
            UIView.animate(withDuration: animationDuration, 
                          delay: 0,
                          options: [.curveEaseInOut],
                          animations: {
                backgroundView.backgroundColor = UIColor.gray.withAlphaComponent(finalAlpha)
            }, completion: nil)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
