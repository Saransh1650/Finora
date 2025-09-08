//
//  GeminiReponseModel.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 8/9/25.
//

import Foundation

struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    let usageMetadata: UsageMetadata?
}

struct Candidate: Codable {
    let content: GeminiContent?
    let finishReason: String?
}

struct UsageMetadata: Codable {
    let promptTokenCount: Int?
    let candidatesTokenCount: Int?
    let totalTokenCount: Int?
}
