//
//  AppOcr.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/10/25.
//

import Foundation
import UIKit
import Vision
import VisionKit

class AppOcr {

    // MARK: - Public Methods

    static func extractStockData(
        from image: UIImage,
        completion: @escaping ([ExtractedStock]?, Error?) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion([], nil)
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard
                let observations = request.results
                    as? [VNRecognizedTextObservation]
            else {
                DispatchQueue.main.async {
                    completion([], nil)
                }
                return
            }

            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")

            print("🔍 [AppOcr] Full recognized text:\n\(recognizedText)")

            // Use Gemini to intelligently extract stock data
            Task {
                await GeminiRepo.extractStocksFromOCRText(
                    ocrText: recognizedText
                ) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let extractedStocks):
                            print(
                                "✅ [AppOcr] Gemini extracted \(extractedStocks.count) stocks"
                            )
                            completion(extractedStocks, nil)
                        case .failure(let error):
                            print(
                                "❌ [AppOcr] Gemini extraction failed: \(error)"
                            )
                            completion(
                                nil,
                                error
                            )
                        }
                    }
                }
            }
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("❌ [AppOcr] Error performing OCR: \(error)")
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }

    // MARK: - Private Methods (Fallback)

    /// Fallback method using rule-based parsing if Gemini fails
    private static func parseStockDataFallback(from text: String)
        -> [ExtractedStock]
    {
        print("⚠️ [AppOcr] Using fallback rule-based parsing")
        var extractedStocks: [ExtractedStock] = []
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let trimmedLine = line.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            guard !trimmedLine.isEmpty else { continue }

            print("🔍 [AppOcr] Processing line: \(trimmedLine)")

            // Look for stock symbols
            if let stockSymbol = extractStockSymbol(from: trimmedLine) {
                let numbers = extractNumbers(from: trimmedLine)
                let stock = createStockFromData(
                    symbol: stockSymbol,
                    numbers: numbers,
                    originalLine: trimmedLine
                )

                if stock.quantity != nil || stock.totalInvestment != nil {
                    extractedStocks.append(stock)
                    print("✅ [AppOcr] Extracted stock: \(stockSymbol)")
                }
            }
        }

        // Remove duplicates by symbol, keeping the one with more data
        let uniqueStocks = Dictionary(
            grouping: extractedStocks,
            by: { $0.symbol }
        )
        .mapValues { stocks in
            stocks.max { stock1, stock2 in
                let score1 =
                    (stock1.quantity != nil ? 1 : 0)
                    + (stock1.totalInvestment != nil ? 1 : 0)
                    + (stock1.avgPrice != nil ? 1 : 0)
                let score2 =
                    (stock2.quantity != nil ? 1 : 0)
                    + (stock2.totalInvestment != nil ? 1 : 0)
                    + (stock2.avgPrice != nil ? 1 : 0)
                return score1 < score2
            }!
        }
        .values
        .map { $0 }

        return Array(uniqueStocks)
    }

    private static func extractStockSymbol(from text: String) -> String? {
        let pattern = #"[A-Z]{2,6}(?![a-z])"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..., in: text)

        if let match = regex?.firstMatch(in: text, range: range) {
            let matchRange = Range(match.range, in: text)!
            let symbol = String(text[matchRange])

            // Filter out common words that might match the pattern
            let excludedWords = [
                "THE", "AND", "FOR", "YOU", "ARE", "NOT", "BUT", "CAN", "GET",
                "ALL", "NEW", "NOW", "WAY", "USE", "HER", "HIM", "ONE", "TWO",
                "HOW", "ITS", "OUR", "OUT", "DAY", "MAY", "SAY", "SHE", "TRY",
                "WHO", "BOY", "DID", "HAS", "LET", "PUT", "TOO", "OLD", "ANY",
                "APP", "BUY", "TOP", "BAD", "BIG", "YES", "WIN", "END",
            ]

            if !excludedWords.contains(symbol) && symbol.count >= 3 {
                return symbol
            }
        }

        return nil
    }

    private static func extractNumbers(from text: String) -> [Double] {
        let pattern = #"[\d,]+\.?\d*"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..., in: text)

        let matches = regex?.matches(in: text, range: range) ?? []
        return matches.compactMap { match in
            let matchRange = Range(match.range, in: text)!
            let numberString = String(text[matchRange]).replacingOccurrences(
                of: ",",
                with: ""
            )
            return Double(numberString)
        }
    }

    private static func createStockFromData(
        symbol: String,
        numbers: [Double],
        originalLine: String
    ) -> ExtractedStock {
        var quantity: Double?
        var totalInvestment: Double?
        var avgPrice: Double?

        // Sort numbers to help identify patterns
        let sortedNumbers = numbers.sorted()

        // Heuristics to identify what each number might represent
        // Larger numbers are likely investment amounts, smaller ones might be quantities or prices

        if numbers.count >= 2 {
            // If we have 2+ numbers, try to identify patterns
            let largestNumber = sortedNumbers.last!
            let smallestNumber = sortedNumbers.first!

            // If largest number is much bigger than smallest, largest is likely investment
            if largestNumber > smallestNumber * 10 {
                totalInvestment = largestNumber

                // Check if any smaller number could be quantity (usually < 10000 shares)
                if let potentialQuantity = sortedNumbers.first(where: {
                    $0 < 10000 && $0 > 0
                }) {
                    quantity = potentialQuantity
                }

                // Calculate average price if we have both
                if let q = quantity, let inv = totalInvestment {
                    avgPrice = inv / q
                }
            }
        } else if numbers.count == 1 {
            let number = numbers.first!
            // Single number heuristic: if it's large (>1000), likely investment; if small, likely quantity
            if number > 1000 {
                totalInvestment = number
            } else if number > 0 {
                quantity = number
            }
        }

        return ExtractedStock(
            symbol: symbol,
            quantity: quantity,
            totalInvestment: totalInvestment,
            avgPrice: avgPrice,
            confidence: 0.7  // Base confidence
        )
    }
}
