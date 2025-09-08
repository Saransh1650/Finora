//
//  AIRepo.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import Foundation

class GeminiRepo {
    static let baseUrl = AppConfig.geminiBaseUrl
    static let apiKey = AppConfig.geminiApiKey
    static let modelId = AppConfig.geminiModelId

    static func analyzePortfolio(
        portfolioData: String,
        completion: @escaping (Result<PortfolioAnalysisModel, Error>) -> Void
    ) async {
        let prompt = createPortfolioAnalysisPrompt(portfolioData: portfolioData)

        let request = GeminiRequest(
            contents: [
                GeminiContent(
                    role: "user",
                    parts: [Part(text: prompt)]
                )
            ],
            generationConfig: GenerationConfig(
                thinkingConfig: ThinkingConfig(thinkingBudget: -1)
            ),
            tools: [
                Tool(googleSearch: GoogleSearch())
            ]
        )

        await sendGeminiRequest(request: request, completion: completion)
    }

    static func createPortfolioAnalysisPrompt(portfolioData: String) -> String {
        return """
            You are a financial research assistant.  
            I will provide you with a list of Indian stocks in my portfolio with details like:  
            - Stock name  
            - Invested amount  
            - Current value  
            
            Your job:  
            1. Fetch the latest relevant financial information from the internet (stock price, fair value estimates, analyst targets, technical support/resistance, sector outlook, and news if any). The prices should be accurate and correct according to the market.  
            2. Analyze my portfolio for diversification, risks, and concentration.  
            3. For each stock, calculate:  
            - Current P&L %  
            - Fair Price range (based on intrinsic value, analyst consensus, or models)  
            - Recommendation: {Add, Hold, Reduce, Exit}  
            - Reason (short explanation)  
            4. Suggest diversification opportunities across sectors  
            5. For the rebalancing plan, recommend both:
            - Actions for existing stocks (sell, hold)
            - New stocks to purchase in underrepresented sectors to improve diversification
            6. Return all results strictly in JSON format with this schema: 
            
            Portfolio Data:
            \(portfolioData)
            
            
            {
            "portfolio_summary": {
            "total_invested": number,
            "current_value": number,
            "pnl_percent": number,
            "concentration_risk": string,
            "diversification_advice": string
            },
            "stocks": [
            {
            "name": string,
            "invested": number,
            "current_value": number,
            "pnl_percent": number,
            "fair_price_estimate": {
            "min_price": number,
            "max_price": number
            },
            "valuation": "Undervalued" | "Fairly Valued" | "Overvalued",
            "recommendation": "Add" | "Hold" | "Reduce" | "Exit",
            "reason": string
            }
            ],
            "rebalancing_plan": [
            {
            "action": "Sell" | "Buy" | "Hold",
            "stock": string,
            "amount": number,
            "rationale": string,
            "fair_entry_range": {
            "min_price": number,
            "max_price": number
            }
            }
            ]
            }
            
            Rules:
            - Always fill every field.
            - Be concise but clear in the "reason" and "rationale".
            - Use latest financial/market data (don't invent values).  
            - Keep numbers as raw numbers, no formatting like ₹ or commas.  
            - Include at least 2-3 new stock recommendations in underrepresented sectors in the rebalancing plan.
            - For new stock recommendations, set action as "Buy" and provide strong rationale.
            - Do not output anything except the JSON object.
            """
    }

    static func sendGeminiRequest(
        request: GeminiRequest,
        completion: @escaping (Result<PortfolioAnalysisModel, Error>) -> Void
    ) async {
        guard !apiKey.isEmpty else {
            completion(.failure(AIRepoError.missingApiKey))
            return
        }

        let urlString =
            "\(baseUrl)/models/\(modelId):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(AIRepoError.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(
                for: urlRequest
            )

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            // Print the raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw Gemini Response: \(responseString)")
            }

            let geminiResponse = try JSONDecoder().decode(
                GeminiResponse.self,
                from: data
            )

            guard let candidate = geminiResponse.candidates?.first,
                let content = candidate.content,
                let part = content.parts.first
            else {
                completion(.failure(AIRepoError.invalidResponse))
                return
            }

            let responseText = part.text
            print("Gemini Response Text: \(responseText)")

            // Extract JSON from the response text
            let portfolioAnalysis = try parsePortfolioAnalysis(
                from: responseText
            )
            completion(.success(portfolioAnalysis))

        } catch {
            print("AIRepo Error: \(error)")
            completion(.failure(error))
        }
    }

    static func parsePortfolioAnalysis(from text: String) throws
        -> PortfolioAnalysisModel
    {
        // Find JSON in the response text
        let jsonStartPattern = "{"
        let jsonEndPattern = "}"

        guard let startIndex = text.firstIndex(of: Character(jsonStartPattern)),
            let endIndex = text.lastIndex(of: Character(jsonEndPattern))
        else {
            throw AIRepoError.invalidJSONFormat
        }

        let jsonString = String(text[startIndex...endIndex])
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIRepoError.invalidJSONFormat
        }

        do {
            let portfolioAnalysis = try JSONDecoder().decode(
                PortfolioAnalysisModel.self,
                from: jsonData
            )
            return portfolioAnalysis
        } catch {
            // If direct decoding fails, try to clean the JSON
            let cleanedJsonString = cleanJsonString(jsonString)
            guard let cleanedJsonData = cleanedJsonString.data(using: .utf8)
            else {
                throw AIRepoError.invalidJSONFormat
            }

            let portfolioAnalysis = try JSONDecoder().decode(
                PortfolioAnalysisModel.self,
                from: cleanedJsonData
            )
            return portfolioAnalysis
        }
    }

    static func cleanJsonString(_ jsonString: String) -> String {
        var cleaned = jsonString
        // Remove any markdown code block markers
        cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        // Remove any extra whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned
    }
}

// MARK: - Error Types
enum AIRepoError: LocalizedError {
    case missingApiKey
    case invalidURL
    case invalidResponse
    case invalidJSONFormat

    var errorDescription: String? {
        switch self {
        case .missingApiKey:
            return
                "Gemini API key is missing. Please add GEMINI_API_KEY to your app's Info.plist"
        case .invalidURL:
            return "Invalid Gemini API URL"
        case .invalidResponse:
            return "Invalid response from Gemini API"
        case .invalidJSONFormat:
            return "Unable to parse JSON response from Gemini API"
        }
    }
}
