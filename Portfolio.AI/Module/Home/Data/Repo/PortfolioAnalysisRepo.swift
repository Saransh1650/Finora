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
    
    // MARK: - Retry Logic Helper
    private static func shouldRetryError(_ error: Error) -> Bool {
        let errorDescription = error.localizedDescription.lowercased()
        // Check for common retryable errors
        return errorDescription.contains("network") ||
               errorDescription.contains("timeout") ||
               errorDescription.contains("connection") ||
               errorDescription.contains("message too long") ||
               errorDescription.contains("temporary") ||
               errorDescription.contains("unavailable")
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
        
        print("🟢 PortfolioAnalysisRepo Debug: Starting fetchPortfolioAnalysis for userId: \(userId)")
        
        let maxRetries = 3
        var retryCount = 0
        
        while retryCount < maxRetries {
            do {
                let response: [PortfolioAnalysisModel] = try await supabase.from(
                    "portfolio_analysis"
                )
                .select()
                .eq("user_id", value: userId)
                .order("analysis_date", ascending: false)
                .execute()
                .value
                
                print("🟢 PortfolioAnalysisRepo Debug: Successfully fetched \(response.count) portfolio analyses")
                return (response, nil)
            } catch {
                print("🔴 PortfolioAnalysisRepo Debug: Fetch attempt \(retryCount + 1) failed with error: \(error)")
                
                if shouldRetryError(error) {
                    print("🟡 PortfolioAnalysisRepo Debug: Detected retryable error in fetchPortfolioAnalysis, retrying...")
                    
                    retryCount += 1
                    if retryCount < maxRetries {
                        // Brief delay before retry with exponential backoff
                        let delay = Double(retryCount) * 0.5
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                }
                
                return (
                    nil,
                    Failure(
                        message: "Error fetching portfolio analysis: \(error.localizedDescription)",
                        errorType: ErrorType.fetchError
                    )
                )
            }
        }
        
        return (
            nil,
            Failure(
                message: "Failed to fetch portfolio analysis after \(maxRetries) attempts",
                errorType: ErrorType.fetchError
            )
        )
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
        
        print("🟢 PortfolioAnalysisRepo Debug: Starting fetchLatestPortfolioAnalysis for userId: \(userId)")
        
        let maxRetries = 3
        var retryCount = 0
        
        while retryCount < maxRetries {
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
                
                print("🟢 PortfolioAnalysisRepo Debug: Successfully fetched latest portfolio analysis")
                return (response.first, nil)
            } catch {
                print("🔴 PortfolioAnalysisRepo Debug: Fetch latest attempt \(retryCount + 1) failed with error: \(error)")
                
                if shouldRetryError(error) {
                    print("🟡 PortfolioAnalysisRepo Debug: Detected retryable error in fetchLatestPortfolioAnalysis, retrying...")
                    
                    retryCount += 1
                    if retryCount < maxRetries {
                        // Brief delay before retry with exponential backoff
                        let delay = Double(retryCount) * 0.5
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                }
                
                return (
                    nil,
                    Failure(
                        message: "Error fetching latest portfolio analysis: \(error.localizedDescription)",
                        errorType: ErrorType.fetchError
                    )
                )
            }
        }
        
        return (
            nil,
            Failure(
                message: "Failed to fetch latest portfolio analysis after \(maxRetries) attempts",
                errorType: ErrorType.fetchError
            )
        )
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
        
        print("🟢 PortfolioAnalysisRepo Debug: Starting savePortfolioAnalysis for userId: \(userId)")
        
        let maxRetries = 2
        var retryCount = 0
        
        while retryCount < maxRetries {
            do {
                try await supabase.from("portfolio_analysis")
                    .insert(userAnalysis)
                    .execute()
                
                print("🟢 PortfolioAnalysisRepo Debug: Successfully saved portfolio analysis")
                completion(.success(()))
                return
            } catch {
                print("🔴 PortfolioAnalysisRepo Debug: Save attempt \(retryCount + 1) failed with error: \(error)")
                
                if shouldRetryError(error) {
                    print("🟡 PortfolioAnalysisRepo Debug: Detected retryable error in savePortfolioAnalysis, retrying...")
                    
                    retryCount += 1
                    if retryCount < maxRetries {
                        // Brief delay before retry
                        let delay = Double(retryCount) * 0.3
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                }
                
                completion(.failure(error))
                return
            }
        }
        
        completion(.failure(Failure(
            message: "Failed to save portfolio analysis after \(maxRetries) attempts",
            errorType: ErrorType.insertError
        )))
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
        
        print("🟢 PortfolioAnalysisRepo Debug: Starting updatePortfolioAnalysis for userId: \(userId), analysisId: \(analysisId)")
        
        let maxRetries = 2
        var retryCount = 0
        
        while retryCount < maxRetries {
            do {
                try await supabase.from("portfolio_analysis")
                    .update(analysis)
                    .eq("id", value: analysisId.uuidString)
                    .eq("user_id", value: userId)
                    .execute()
                
                print("🟢 PortfolioAnalysisRepo Debug: Successfully updated portfolio analysis")
                completion(.success(()))
                return
            } catch {
                print("🔴 PortfolioAnalysisRepo Debug: Update attempt \(retryCount + 1) failed with error: \(error)")
                
                if shouldRetryError(error) {
                    print("🟡 PortfolioAnalysisRepo Debug: Detected retryable error in updatePortfolioAnalysis, retrying...")
                    
                    retryCount += 1
                    if retryCount < maxRetries {
                        // Brief delay before retry
                        let delay = Double(retryCount) * 0.3
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                }
                
                completion(.failure(error))
                return
            }
        }
        
        completion(.failure(Failure(
            message: "Failed to update portfolio analysis after \(maxRetries) attempts",
            errorType: ErrorType.updateError
        )))
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
        
        print("🟢 PortfolioAnalysisRepo Debug: Starting deletePortfolioAnalysis for userId: \(userId), analysisId: \(id)")
        
        let maxRetries = 2
        var retryCount = 0
        
        while retryCount < maxRetries {
            do {
                try await supabase.from("portfolio_analysis")
                    .delete()
                    .eq("id", value: id)
                    .eq("user_id", value: userId)
                    .execute()
                
                print("🟢 PortfolioAnalysisRepo Debug: Successfully deleted portfolio analysis")
                completion(.success(()))
                return
            } catch {
                print("🔴 PortfolioAnalysisRepo Debug: Delete attempt \(retryCount + 1) failed with error: \(error)")
                
                if shouldRetryError(error) {
                    print("🟡 PortfolioAnalysisRepo Debug: Detected retryable error in deletePortfolioAnalysis, retrying...")
                    
                    retryCount += 1
                    if retryCount < maxRetries {
                        // Brief delay before retry
                        let delay = Double(retryCount) * 0.3
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                }
                
                completion(.failure(error))
                return
            }
        }
        
        completion(.failure(Failure(
            message: "Failed to delete portfolio analysis after \(maxRetries) attempts",
            errorType: ErrorType.deleteError
        )))
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
        
        print("🟢 PortfolioAnalysisRepo Debug: Starting deleteAllPortfolioAnalyses for userId: \(userId)")
        
        let maxRetries = 2
        var retryCount = 0
        
        while retryCount < maxRetries {
            do {
                try await supabase.from("portfolio_analysis")
                    .delete()
                    .eq("user_id", value: userId)
                    .execute()
                
                print("🟢 PortfolioAnalysisRepo Debug: Successfully deleted all portfolio analyses")
                completion(.success(()))
                return
            } catch {
                print("🔴 PortfolioAnalysisRepo Debug: Delete all attempt \(retryCount + 1) failed with error: \(error)")
                
                if shouldRetryError(error) {
                    print("🟡 PortfolioAnalysisRepo Debug: Detected retryable error in deleteAllPortfolioAnalyses, retrying...")
                    
                    retryCount += 1
                    if retryCount < maxRetries {
                        // Brief delay before retry
                        let delay = Double(retryCount) * 0.3
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                }
                
                completion(.failure(error))
                return
            }
        }
        
        completion(.failure(Failure(
            message: "Failed to delete all portfolio analyses after \(maxRetries) attempts",
            errorType: ErrorType.deleteError
        )))
    }
}
