//
//  AIRepo.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import Foundation
import OpenAI

class AIRepo {
    static var configuration = OpenAI.Configuration(
        token:
            "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",
        timeoutInterval: 60.0
    )
    static var openAI: OpenAI?
    static var client: OpenAIProtocol?

    init() {
        AIRepo.openAI = OpenAI(configuration: AIRepo.configuration)
        AIRepo.client = OpenAI(configuration: AIRepo.configuration)
    }

    static let query = CreateModelResponseQuery(
        input: .textInput(
            "You are a financial research assistant.  \n                      I will provide you with a list of Indian stocks in my portfolio with details like:\n                        - Stock name\n                      - Invested amount\n                      - Current value\n                      \n                      Your job:\n                        1. Fetch the latest relevant financial information from the internet (stock price, fair value estimates, analyst targets, technical support/resistance, sector outlook, and news if any).\n                      2. Analyze my portfolio for diversification, risks, and concentration.\n                      3. For each stock, calculate:\n                        - Current P&L %\n                      - Fair Price range (based on intrinsic value, analyst consensus, or models)\n                      - Recommendation: {Add, Hold, Reduce, Exit}\n                      - Reason (short explanation)\n                      4. Suggest diversification opportunities across sectors (like IT, banking, FMCG, pharma, etc.).\n                      5. Return all results strictly in JSON format with this schema:\n                        \n                        {\n                            \"portfolio_summary\": {\n                                \"total_invested\": number,\n                                \"current_value\": number,\n                                \"pnl_percent\": number,\n                                \"concentration_risk\": string,\n                                \"diversification_advice\": string\n                            },\n                            \"stocks\": [\n                                {\n                                    \"name\": string,\n                                    \"invested\": number,\n                                    \"current_value\": number,\n                                    \"pnl_percent\": number,\n                                    \"fair_price_estimate\": number,\n                                    \"valuation\": \"Undervalued\" | \"Fairly Valued\" | \"Overvalued\",\n                                    \"recommendation\": \"Add\" | \"Hold\" | \"Reduce\" | \"Exit\",\n                                    \"reason\": string\n                                }\n                            ],\n                            \"rebalancing_plan\": [\n                                {\n                                    \"action\": \"Sell/Buy/Hold\",\n                                    \"stock\": string,\n                                    \"amount\": number,\n                                    \"rationale\": string\n                                }\n                            ]\n                        }\n                      \n                      Rules:\n                        - Always fill every field.\n                      - Be concise but clear in the \"reason\" and \"rationale\".\n                      - Use latest financial/market data (don’t invent values).\n                      - Keep numbers as raw numbers, no formatting like ₹ or commas.\n                      - Do not output anything except the JSON object. Stocks:   - ABFRL: Invested 5404, Current 5573 - BSE: Invested 10133, Current 8665 - PTC: Invested 2418, Current 2332         - Raymond: Invested 10013, Current 8589   "
        ),
        model: .gpt4_1
    )

    static func fetchAIResponse() async {
        do {
            guard let client = client else {
                print("OpenAI client not initialized")
                return
            }
            let response: ResponseObject = try await client.responses
                .createResponse(query: query)
            print("Full Response: \(response)")
        } catch {
            print("Error fetching AI response: \(error)")
        }
    }
}
