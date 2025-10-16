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
    let tools: [Tool]?
    
    init(contents: [GeminiContent], generationConfig: GenerationConfig, tools: [Tool]? = nil) {
        self.contents = contents
        self.generationConfig = generationConfig
        self.tools = tools
    }
}

struct GeminiContent: Codable {
    let role: String
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}

struct GenerationConfig: Codable {
    let thinkingConfig: ThinkingConfig?
    let temperature: Double?
    let topP: Double?
    let topK: Int?
    let maxOutputTokens: Int?
    
    init(thinkingConfig: ThinkingConfig) {
        self.thinkingConfig = thinkingConfig
        self.temperature = nil
        self.topP = nil
        self.topK = nil
        self.maxOutputTokens = nil
    }
    
    init(temperature: Double? = nil, topP: Double? = nil, topK: Int? = nil, maxOutputTokens: Int? = nil) {
        self.thinkingConfig = nil
        self.temperature = temperature
        self.topP = topP
        self.topK = topK
        self.maxOutputTokens = maxOutputTokens
    }
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
