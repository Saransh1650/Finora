//
//  PortfolioAnalysisRepo.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 10/9/25.
//

import Foundation
import Supabase

class PortfolioAnalysisRepo {
    private static let apiClient = Api.shared
    private static let supabase = SupabaseManager.shared.client

    static private var currentUserId: String? {
        (supabase.auth.currentUser?.id.uuidString)
    }

    static func fetchPortfolioAnalysis() async -> (
        [PortfolioAnalysisModel]?, Failure?
    ) {
        guard currentUserId != nil else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: ErrorType.fetchError
                )
            )
        }

        let (result, error) = await apiClient.sendRequest(
            path: AppEndpoints.portfolio,
            method: .get
        )

        if let error = error {
            return (nil, error)
        }
        
        guard let resultDict = result as? [String: Any],
              let success = resultDict["success"] as? Bool,
              success == true,
              let dataArray = resultDict["data"] as? [[String: Any]] else {
            return (nil, Failure(message: "Invalid response format", errorType: .parseError))
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataArray)
            let analyses = try JSONDecoder().decode([PortfolioAnalysisModel].self, from: jsonData)
            return (analyses, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: "Error parsing portfolio analysis: \(error.localizedDescription)",
                    errorType: ErrorType.parseError
                )
            )
        }
    }

    static func fetchLatestPortfolioAnalysis() async -> (
        PortfolioAnalysisModel?, Failure?
    ) {
        guard currentUserId != nil else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: ErrorType.fetchError
                )
            )
        }

        let (result, error) = await apiClient.sendRequest(
            path: AppEndpoints.latestPortfolio,
            method: .get
        )

        if let error = error {
            return (nil, error)
        }
        
        guard let resultDict = result as? [String: Any],
              let success = resultDict["success"] as? Bool,
              success == true,
              let dataDict = resultDict["data"] as? [String: Any] else {
            return (nil, Failure(message: "Invalid response format", errorType: .parseError))
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataDict)
            let analysis = try JSONDecoder().decode(PortfolioAnalysisModel.self, from: jsonData)
            return (analysis, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: "Error parsing latest portfolio analysis: \(error.localizedDescription)",
                    errorType: ErrorType.parseError
                )
            )
        }
    }

    static func savePortfolioAnalysis(
        _ portfolio: PortfolioAnalysisModel,
        _ analysis: PortfolioSummaryByAiModel?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard currentUserId != nil else {
            completion(
                .failure(
                    Failure(
                        message: "User not authenticated",
                        errorType: ErrorType.fetchError
                    )
                )
            )
            return
        }

        // Create the analysis data to send to the backend
        let analysisData = PortfolioAnalysisModel(
            id: portfolio.id,
            userId: portfolio.userId,
            portfolioSummaryByAiModel: analysis,
            analysisDate: portfolio.analysisDate ?? Date(),
            createdAt: portfolio.createdAt,
            updatedAt: portfolio.updatedAt
        )

        let (_, error) = await apiClient.sendRequest(
            path: AppEndpoints.portfolio,
            method: .post,
            body: try? analysisData.toDictionary()
        )
        
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }

    static func updatePortfolioAnalysis(
        _ analysis: PortfolioAnalysisModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard currentUserId != nil,
            let analysisId = analysis.id
        else {
            completion(
                .failure(
                    Failure(
                        message:
                            "User not authenticated or analysis ID missing",
                        errorType: ErrorType.fetchError
                    )
                )
            )
            return
        }

        let (_, error) = await apiClient.sendRequest(
            path: AppEndpoints.portfolioById(id: analysisId.uuidString),
            method: .put,
            body: try? analysis.toDictionary()
        )
        
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }

    static func deletePortfolioAnalysis(
        withId id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard currentUserId != nil else {
            completion(
                .failure(
                    Failure(
                        message: "User not authenticated",
                        errorType: ErrorType.fetchError
                    )
                )
            )
            return
        }

        let (_, error) = await apiClient.sendRequest(
            path: AppEndpoints.portfolioById(id: id),
            method: .delete
        )
        
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }

    static func deleteAllPortfolioAnalyses(
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard currentUserId != nil else {
            completion(
                .failure(
                    Failure(
                        message: "User not authenticated",
                        errorType: ErrorType.fetchError
                    )
                )
            )
            return
        }

        // First fetch all portfolio analyses to get their IDs
        let (fetchResult, fetchError) = await apiClient.sendRequest(
            path: AppEndpoints.portfolio,
            method: .get
        )

        if let fetchError = fetchError {
            completion(.failure(fetchError))
            return
        }
        
        guard let resultDict = fetchResult as? [String: Any],
              let success = resultDict["success"] as? Bool,
              success == true,
              let dataArray = resultDict["data"] as? [[String: Any]] else {
            completion(.success(())) // No analyses to delete
            return
        }

        if dataArray.isEmpty {
            completion(.success(()))
            return
        }

        // Delete each analysis individually since the backend doesn't have a bulk delete for portfolio
        var hasError = false
        for analysisDict in dataArray {
            if let analysisId = analysisDict["id"] as? String {
                let (_, error) = await apiClient.sendRequest(
                    path: AppEndpoints.portfolioById(id: analysisId),
                    method: .delete
                )
                if error != nil {
                    hasError = true
                    completion(.failure(error!))
                    return
                }
            }
        }
        
        if !hasError {
            completion(.success(()))
        }
    }
}
