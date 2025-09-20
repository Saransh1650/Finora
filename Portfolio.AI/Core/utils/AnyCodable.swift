//
//  AnyCodable.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 20/9/25.
//

import Foundation

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal
        } else {
            value = ()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
            case let intVal as Int:
                try container.encode(intVal)
            case let doubleVal as Double:
                try container.encode(doubleVal)
            case let boolVal as Bool:
                try container.encode(boolVal)
            case let stringVal as String:
                try container.encode(stringVal)
            case let dictVal as [String: AnyCodable]:
                try container.encode(dictVal)
            case let arrayVal as [AnyCodable]:
                try container.encode(arrayVal)
            default:
                try container.encodeNil()
        }
    }
}
