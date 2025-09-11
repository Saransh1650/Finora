//
//  PortfolioAnalysisRepo.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 10/9/25.
//

import Foundation
import Supabase

class PortfolioAnalysisRepo {
    static private let supabase = SupabaseManager.shared.client

    static private var currentUserId: String? {
        (supabase.auth.currentUser?.id.uuidString)
    }

    static func fetchPortfolioAnalysis() async -> (
        [PortfolioAnalysisModel]?, Failure?
    ) {
        guard let userId = currentUserId else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: ErrorType.fetchError
                )
            )
        }
        do {
            let response: [PortfolioAnalysisModel] = try await supabase.from(
                "portfolio_analysis"
            )
            .select()
            .eq("user_id", value: userId)
            .order("analysis_date", ascending: false)
            .execute()
            .value
            return (response, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: "Error fetching portfolio analysis",
                    errorType: ErrorType.fetchError
                )
            )
        }
    }

    static func fetchLatestPortfolioAnalysis() async -> (
        PortfolioAnalysisModel?, Failure?
    ) {
        guard let userId = currentUserId else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: ErrorType.fetchError
                )
            )
        }
        do {
            let response: [PortfolioAnalysisModel] = try await supabase.from(
                "portfolio_analysis"
            )
            .select()
            .eq("user_id", value: userId)
            .order("analysis_date", ascending: false)
            .limit(1)
            .execute()
            .value
            return (response.first, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: "Error fetching latest portfolio analysis",
                    errorType: ErrorType.fetchError
                )
            )
        }
    }

    static func savePortfolioAnalysis(
        _ portfolio: PortfolioAnalysisModel,
        _ analysis: PortfolioSummaryByAiModel?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard let userId = currentUserId else {
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

        // Ensure analysis has the correct userId
        var userAnalysis = portfolio
        userAnalysis = PortfolioAnalysisModel(
            id: portfolio.id,
            userId: userId,
            portfolioSummaryByAiModel: analysis,
            analysisDate: portfolio.analysisDate ?? Date(),
            createdAt: portfolio.createdAt,
            updatedAt: portfolio.updatedAt
        )

        do {
            try await supabase.from("portfolio_analysis")
                .insert(userAnalysis)
                .execute()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    static func updatePortfolioAnalysis(
        _ analysis: PortfolioAnalysisModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard let userId = currentUserId,
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

        do {
            try await supabase.from("portfolio_analysis")
                .update(analysis)
                .eq("id", value: analysisId.uuidString)
                .eq("user_id", value: userId)
                .execute()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    static func deletePortfolioAnalysis(
        withId id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard let userId = currentUserId else {
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

        do {
            try await supabase.from("portfolio_analysis")
                .delete()
                .eq("id", value: id)
                .eq("user_id", value: userId)
                .execute()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    static func deleteAllPortfolioAnalyses(
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard let userId = currentUserId else {
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

        do {
            try await supabase.from("portfolio_analysis")
                .delete()
                .eq("user_id", value: userId)
                .execute()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
