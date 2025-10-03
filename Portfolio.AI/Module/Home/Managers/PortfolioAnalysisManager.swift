//
//  PortfolioAnalysisManager.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 7/9/25.
//

import Foundation
import SwiftUI

@MainActor
class PortfolioAnalysisManager: ObservableObject {
    @Published var currentAnalysis: PortfolioAnalysisModel?
    @Published var analysisHistory: [PortfolioAnalysisModel] = []
    @Published var portfolioSummaryByAiModel: PortfolioSummaryByAiModel?
    @Published var isLoading: Bool = false
    @Published var fetchLoading: Bool = false
    @Published var errorMessage: String?
    @Published var canAnalyzeToday: Bool = true

    init() {
        fetchLatestAnalysis()
        checkDailyAnalysisLimit()
    }

    // MARK: - Fetch Operations

    /// Fetch all portfolio analysis for the current user
    func fetchAnalysisHistory() async {
        isLoading = true
        errorMessage = nil

        let (analyses, error) =
            await PortfolioAnalysisRepo.fetchPortfolioAnalysis()

        if let analyses = analyses {
            analysisHistory = analyses
            currentAnalysis = analyses.first  // Latest analysis
        } else if let error = error {
            errorMessage = error.message
        }

        isLoading = false
    }

    /// Fetch the latest portfolio analysis for the current user
    func fetchLatestAnalysis() {
        print("Fetching latest analysis")
        fetchLoading = true
        errorMessage = nil

        Task {
            do {
                let (analysis, error) =
                    await PortfolioAnalysisRepo.fetchLatestPortfolioAnalysis()

                if let analysis = analysis {
                    print(
                        "fetched current analysis from db: \(analysis.userId)"
                    )
                    currentAnalysis = analysis
                    checkDailyAnalysisLimit()
                } else if let error = error {
                    print(
                        "Error fetching latest analysis: \(String(describing: error.message))"
                    )
                    errorMessage = error.message
                }
            }
        }

        fetchLoading = false
    }

    // MARK: - Generate summary and save portfolio

    /// Generate portfolio summary using Gemini API and save it
    func generateSummaryAndSave(stocks: [StockModel]) async {
        // Check daily limit first
        guard canAnalyzeToday else {
            errorMessage = "You can only perform one analysis per day. Next analysis available \(timeUntilNextAnalysis ?? "tomorrow")."
            return
        }
        
        isLoading = true
        errorMessage = nil

        do {
            let portfolioData = try JSONEncoder().encode(stocks)
            let portfolioJsonString =
                String(data: portfolioData, encoding: .utf8)
                ?? "No portfolio data"

            await GeminiRepo.analyzePortfolio(
                portfolioData: portfolioJsonString
            ) { result in

                DispatchQueue.main.async {
                    self.isLoading = false

                    switch result {
                    case .success(let analysis):
                        print("AI Analysis Result: \(analysis)")
                        self.currentAnalysis = PortfolioAnalysisModel(
                            userId: SupabaseManager.shared.client.auth
                                .currentUser?.id.uuidString ?? "",
                            portfolioSummaryByAiModel: analysis,
                            analysisDate: Date(),
                            createdAt: Date(),
                            updatedAt: Date(),
                        )

                        Task {
                            await self.saveAnalysis(self.currentAnalysis!)
                            // Update daily limit after successful analysis
                            self.checkDailyAnalysisLimit()
                        }

                    case .failure(let error):
                        print(
                            "Portfolio Analysis Error: \(error.localizedDescription)"
                        )

                        self.errorMessage =
                            "Failed to analyze portfolio. Please try again."
                    }
                }

            }

        } catch {
            isLoading = false
            errorMessage =
                "Error encoding portfolio data: \(error.localizedDescription)"
            print("Error encoding portfolio data: \(error)")
        }

    }

    // MARK: - Save Operations

    /// Save a new portfolio analysis
    func saveAnalysis(_ analysis: PortfolioAnalysisModel) async {
        isLoading = true
        errorMessage = nil

        await PortfolioAnalysisRepo.savePortfolioAnalysis(
            analysis,
            currentAnalysis?.portfolioSummaryByAiModel
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    // Refresh the analysis history after successful save
                    Task {
                        await self?.fetchAnalysisHistory()
                    }
                case .failure(let error):
                    print("Save Analysis Error: \(error)")
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }

    /// Update an existing portfolio analysis
    func updateAnalysis(_ analysis: PortfolioAnalysisModel) async {
        isLoading = true
        errorMessage = nil

        await PortfolioAnalysisRepo.updatePortfolioAnalysis(analysis) {
            [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    // Refresh the analysis history after successful update
                    Task {
                        await self?.fetchAnalysisHistory()
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }

    // MARK: - Delete Operations

    /// Delete a specific portfolio analysis
    func deleteAnalysis(withId id: String) async {
        isLoading = true
        errorMessage = nil

        await PortfolioAnalysisRepo.deletePortfolioAnalysis(withId: id) {
            [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    // Remove from local arrays and refresh
                    self?.analysisHistory.removeAll { $0.id?.uuidString == id }
                    if self?.currentAnalysis?.id?.uuidString == id {
                        self?.currentAnalysis = self?.analysisHistory.first
                    }
                    self?.isLoading = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }

    /// Delete all portfolio analyses for the current user
    func deleteAllAnalyses() async {
        isLoading = true
        errorMessage = nil

        await PortfolioAnalysisRepo.deleteAllPortfolioAnalyses {
            [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.analysisHistory.removeAll()
                    self?.currentAnalysis = nil
                    self?.isLoading = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }

    // MARK: - Daily Limit Checking
    
    /// Check if user can perform analysis today (max 1 per day)
    private func checkDailyAnalysisLimit() {
        guard let lastAnalysis = currentAnalysis,
              let lastAnalysisDate = lastAnalysis.analysisDate else {
            canAnalyzeToday = true
            return
        }
        
        let calendar = Calendar.current
        canAnalyzeToday = !calendar.isDateInToday(lastAnalysisDate)
    }
    
    /// Get time until next analysis is allowed
    var timeUntilNextAnalysis: String? {
        guard !canAnalyzeToday,
              let lastAnalysis = currentAnalysis,
              let lastAnalysisDate = lastAnalysis.analysisDate else {
            return nil
        }
        
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: lastAnalysisDate),
           let startOfTomorrow = calendar.dateInterval(of: .day, for: tomorrow)?.start {
            let timeRemaining = startOfTomorrow.timeIntervalSinceNow
            if timeRemaining > 0 {
                let hours = Int(timeRemaining) / 3600
                return "\(hours)h"
            }
        }
        return nil
    }

    // MARK: - Utility Methods

    /// Clear error message
    func clearError() {
        errorMessage = nil
    }

    /// Check if there's any analysis data
    var hasAnalysis: Bool {
        !analysisHistory.isEmpty
    }

    /// Get analysis count
    var analysisCount: Int {
        analysisHistory.count
    }
}
