//
//  AIRepo.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import Foundation

// Note: Import needed ChatMessage model - this may need to be adjusted based on your project structure
// Assuming ChatMessage is accessible from this context

// MARK: - OCR Stock Extraction Model
struct ExtractedStock {
    let symbol: String
    let quantity: Double?
    let totalInvestment: Double?
    let avgPrice: Double?
    let confidence: Float
}

// MARK: - Chat Response Model
struct ChatResponseModel {
    let content: String
    let tokensUsed: Int
    let finishReason: String?
}

class GeminiRepo {
    static let baseUrl = AppConfig.geminiBaseUrl
    static let apiKey = AppConfig.geminiApiKey
    static let geminiPro = AppConfig.geminiModelPro
    static let geminiFlash = AppConfig.geminiModeFlash

    static func analyzePortfolio(
        portfolioData: String,
        completion: @escaping (Result<PortfolioSummaryByAiModel, Error>) -> Void
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

    /// Extract stock information from OCR text using Gemini AI
    /// - Parameters:
    ///   - ocrText: Raw text extracted from OCR
    ///   - completion: Completion handler with extracted stocks or error
    static func extractStocksFromOCRText(
        ocrText: String,
        completion: @escaping (Result<[ExtractedStock], Error>) -> Void
    ) async {
        print("🤖 [GeminiRepo] Starting intelligent stock extraction from OCR text")
        print("📝 [GeminiRepo] OCR text length: \(ocrText.count) characters")
        
        let prompt = createStockExtractionPrompt(ocrText: ocrText)

        let request = GeminiRequest(
            contents: [
                GeminiContent(
                    role: "user",
                    parts: [Part(text: prompt)]
                )
            ],
            generationConfig: GenerationConfig(
                temperature: 0.1, // Low temperature for more consistent extraction
                topP: 0.8,
                topK: 40,
                maxOutputTokens: 2048
            )
        )

        await sendStockExtractionRequest(request: request, completion: completion)
    }

    static func getChatResponse(
        userMessage: String,
        conversationHistory: [ChatMessage]? = nil,
        portfolioContext: String? = nil,
        completion: @escaping (Result<ChatResponseModel, Error>) -> Void
    ) async {
        let prompt = createChatPrompt(
            userMessage: userMessage, 
            conversationHistory: conversationHistory,
            portfolioContext: portfolioContext
        )

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

        await sendChatRequest(request: request, completion: completion)
    }

    static func createStockExtractionPrompt(ocrText: String) -> String {
        return """
            You are an expert financial data extraction AI. I will provide you with OCR text from a portfolio screenshot or document, and you need to extract stock information from it.

            Your task:
            1. Identify stock symbols (like AAPL, TSLA, RELIANCE, TCS, etc.)
            2. Extract quantities (number of shares)
            3. Extract investment amounts or current values
            4. Calculate average prices when possible
            5. Assign confidence scores based on how clear the data is

            OCR Text to analyze:
            ```
            \(ocrText)
            ```

            Rules:
            - Only extract data that clearly represents stocks/equities
            - Ignore headers, footers, dates, or non-stock related text
            - Stock symbols are typically 2-6 uppercase letters
            - Be conservative with confidence scores (0.0 to 1.0)
            - If a number could be quantity OR investment, use context clues
            - Handle Indian stock symbols (like RELIANCE, TCS, INFY) and US symbols (AAPL, TSLA)
            - Ignore common words that look like stock symbols
            - If data is unclear or incomplete, still include it but with lower confidence

            Return ONLY a JSON array in this exact format:
            [
              {
                "symbol": "AAPL",
                "quantity": 10.0,
                "totalInvestment": 1500.0,
                "avgPrice": 150.0,
                "confidence": 0.9
              }
            ]

            Important:
            - If you can't find quantity or investment, set to null
            - avgPrice = totalInvestment / quantity (if both available)
            - confidence should reflect how certain you are about the data
            - Return empty array [] if no stocks found
            - Do not include any explanation, only the JSON array
            """
    }

    static func createChatPrompt(
        userMessage: String, 
        conversationHistory: [ChatMessage]? = nil,
        portfolioContext: String? = nil
    ) -> String {
        var prompt = """
            You are Portfolio AI, an intelligent financial assistant specializing in investment portfolio management and analysis. 
            You have access to real-time market data and can help users with:
            
            1. Portfolio analysis and optimization
            2. Investment research and recommendations
            3. Risk assessment and management
            4. Market trends and insights
            5. Financial planning and strategy
            
            Guidelines:
            - Provide accurate, data-driven insights
            - Be concise but comprehensive in your responses
            - Use real-time market data when available
            - Always consider risk factors in recommendations
            - Maintain a professional but friendly tone
            - If asked about specific stocks, provide current market data
            - Keep it like a chat messaging between you and user, and answer in short like humans talk 
            - Ask questions if needed
            - do not answer in parts, if the answer is getting long just end it with a question if the user wants more or not
            
            """
        
        // Add portfolio context if available and enabled
            prompt += "\n--- USER'S PORTFOLIO CONTEXT ---\n"
            
            if let summary = portfolioContext {
                prompt += """
                Portfolio Summary:
                \(summary)
                """
            }
            
            prompt += "\n--- END PORTFOLIO CONTEXT ---\n\n"
        
        
        // Add conversation history if available
        if let history = conversationHistory, !history.isEmpty {
            prompt += "Conversation History:\n"
            let recentHistory = Array(history.suffix(5)) // Include last 5 messages for context
            for message in recentHistory {
                let role = message.role == .user ? "User" : "Assistant"
                prompt += "\(role): \(message.content)\n"
            }
            prompt += "\n"
        }
        
        prompt += "User's current question: \(userMessage)\n\nPlease provide a helpful response:"
        print("prompt: \(prompt)")
        return prompt
    }

    static func createPortfolioAnalysisPrompt(portfolioData: String) -> String {
        return """
            You are a financial research assistant.  
            I will provide you with a list of stocks in my portfolio with details like:  
            - Stock name  
            - Invested amount  
            - Current value  
            
            Portfolio Data:
            \(portfolioData)

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


            Output Schema:
            \(PortfolioSummaryByAiModel.jsonSchema())

            Rules:
            - Always fill every field.
            - Use latest financial/market data (don't invent values), search net to get the values dont get wrong data. 
            - The "valuation" field MUST be exactly one of: "overvalued", "undervalued", "fairly valued", or "fair" (lowercase only, no other variations).
            - Be concise but clear in the "reason" and "rationale".
            - Keep numbers as raw numbers, no formatting like ₹ or commas.  
            - Include at least 2-3 new stock recommendations in underrepresented sectors in the rebalancing plan.
            - **Do not recommend the same stock more than once. unless they are highly suitable for the portfolio.**
            - For new stock recommendations, set action as "Buy" and provide strong rationale.
            - Do not output anything except the JSON object.
            """
    }

    static func sendGeminiRequest(
        request: GeminiRequest,
        completion: @escaping (Result<PortfolioSummaryByAiModel, Error>) -> Void
    ) async {
        guard !apiKey.isEmpty else {
            completion(.failure(AIRepoError.missingApiKey))
            return
        }

        let urlString =
            "\(baseUrl)/models/\(geminiFlash):generateContent?key=\(apiKey)"
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
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 300 // Timeout for requests (in seconds)
            config.timeoutIntervalForResource = 300 // Timeout for resources (in seconds)
            let session = URLSession(configuration: config)

            let (data, response) = try await session.data(
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

            let portfolioSummaryByAi = try parsePortfolioAnalysis(
                from: responseText
            )
            completion(.success(portfolioSummaryByAi))

        } catch {
            print("AIRepo Error: \(error)")
            completion(.failure(error))
        }
    }

    static func sendStockExtractionRequest(
        request: GeminiRequest,
        completion: @escaping (Result<[ExtractedStock], Error>) -> Void
    ) async {
        guard !apiKey.isEmpty else {
            completion(.failure(AIRepoError.missingApiKey))
            return
        }

        let urlString = "\(baseUrl)/models/\(geminiFlash):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(AIRepoError.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 60
            config.timeoutIntervalForResource = 60
            let session = URLSession(configuration: config)

            let (data, response) = try await session.data(for: urlRequest)

            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 [GeminiRepo] Stock Extraction HTTP Status: \(httpResponse.statusCode)")
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 [GeminiRepo] Raw Stock Extraction Response: \(responseString)")
            }

            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

            guard let candidate = geminiResponse.candidates?.first,
                  let content = candidate.content,
                  let part = content.parts.first else {
                completion(.failure(AIRepoError.invalidResponse))
                return
            }

            let responseText = part.text
            print("🔍 [GeminiRepo] Stock Extraction Response Text: \(responseText)")

            let extractedStocks = try parseStockExtractionResponse(from: responseText)
            completion(.success(extractedStocks))

        } catch {
            print("❌ [GeminiRepo] Stock Extraction Error: \(error)")
            completion(.failure(error))
        }
    }

    static func sendChatRequest(
        request: GeminiRequest,
        completion: @escaping (Result<ChatResponseModel, Error>) -> Void
    ) async {
        guard !apiKey.isEmpty else {
            completion(.failure(AIRepoError.missingApiKey))
            return
        }

        let urlString =
            "\(baseUrl)/models/\(geminiFlash):generateContent?key=\(apiKey)"
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
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 120 // Shorter timeout for chat
            config.timeoutIntervalForResource = 120
            let session = URLSession(configuration: config)

            let (data, response) = try await session.data(for: urlRequest)

            if let httpResponse = response as? HTTPURLResponse {
                print("Chat HTTP Status Code: \(httpResponse.statusCode)")
            }

            // Print the raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw Chat Response: \(responseString)")
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
            print("Chat Response Text: \(responseText)")

            let chatResponse = ChatResponseModel(
                content: responseText,
                tokensUsed: geminiResponse.usageMetadata?.totalTokenCount ?? 0,
                finishReason: candidate.finishReason
            )
            completion(.success(chatResponse))

        } catch {
            print("Chat AIRepo Error: \(error)")
            completion(.failure(error))
        }
    }

    static func parseStockExtractionResponse(from text: String) throws -> [ExtractedStock] {
        // Clean the response text to extract JSON
        var cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks if present
        cleanedText = cleanedText.replacingOccurrences(of: "```json", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "```", with: "")
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Find JSON array bounds
        guard let startIndex = cleanedText.firstIndex(of: "["),
              let endIndex = cleanedText.lastIndex(of: "]") else {
            print("⚠️ [GeminiRepo] No JSON array found in response")
            return []
        }
        
        let jsonString = String(cleanedText[startIndex...endIndex])
        print("🔍 [GeminiRepo] Extracted JSON: \(jsonString)")
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIRepoError.invalidJSONFormat
        }
        
        // Define a temporary struct for decoding
        struct TempExtractedStock: Codable {
            let symbol: String
            let quantity: Double?
            let totalInvestment: Double?
            let avgPrice: Double?
            let confidence: Double
        }
        
        do {
            let tempStocks = try JSONDecoder().decode([TempExtractedStock].self, from: jsonData)
            
            // Convert to ExtractedStock with Float confidence
            let extractedStocks = tempStocks.map { tempStock in
                ExtractedStock(
                    symbol: tempStock.symbol.uppercased(),
                    quantity: tempStock.quantity,
                    totalInvestment: tempStock.totalInvestment,
                    avgPrice: tempStock.avgPrice,
                    confidence: Float(tempStock.confidence)
                )
            }
            
            print("✅ [GeminiRepo] Successfully parsed \(extractedStocks.count) stocks")
            return extractedStocks
            
        } catch {
            print("❌ [GeminiRepo] JSON parsing error: \(error)")
            throw AIRepoError.invalidJSONFormat
        }
    }

    static func parsePortfolioAnalysis(from text: String) throws
        -> PortfolioSummaryByAiModel
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
            let portfolioSummaryByAi = try JSONDecoder().decode(
                PortfolioSummaryByAiModel.self,
                from: jsonData
            )
            return portfolioSummaryByAi
        } catch {
            // If direct decoding fails, try to clean the JSON
            let cleanedJsonString = cleanJsonString(jsonString)
            guard let cleanedJsonData = cleanedJsonString.data(using: .utf8)
            else {
                throw AIRepoError.invalidJSONFormat
            }

            let portfolioSummaryByAi = try JSONDecoder().decode(
                PortfolioSummaryByAiModel.self,
                from: cleanedJsonData
            )
            return portfolioSummaryByAi
        }
    }

    static func cleanJsonString(_ jsonString: String) -> String {
        var cleaned = jsonString
        cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        cleaned = cleaned.replacingOccurrences(of: "```", with: "")
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
