//
//  EditableStockModel.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/10/25.
//

import Foundation

struct EditableStockModel {
    var totalInvestment: String
    var quantity: String
    
    var isValid: Bool {
        return Double(totalInvestment) != nil
        && Double(totalInvestment)! > 0 && Double(quantity) != nil
        && Double(quantity)! > 0
    }
    }
