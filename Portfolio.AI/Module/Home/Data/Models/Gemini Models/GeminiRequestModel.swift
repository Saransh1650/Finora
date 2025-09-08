//
//  GeminiRequestModel.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 8/9/25.
//

import Foundation

struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GenerationConfig
    let tools: [Tool]
}

struct GeminiContent: Codable {
    let role: String
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}

struct GenerationConfig: Codable {
    let thinkingConfig: ThinkingConfig
}

struct ThinkingConfig: Codable {
    let thinkingBudget: Int
}

struct Tool: Codable {
    let googleSearch: GoogleSearch
}

struct GoogleSearch: Codable {
    init() {}
}
