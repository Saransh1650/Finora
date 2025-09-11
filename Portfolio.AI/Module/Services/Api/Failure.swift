//
//  Failure.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import Foundation

struct Failure: Error {
    var message: String?
    var errorType: ErrorType
}
