//
//  AppOcr.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/10/25.
//

import Foundation
import UIKit
import Vision

class AppOcr {

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
}
