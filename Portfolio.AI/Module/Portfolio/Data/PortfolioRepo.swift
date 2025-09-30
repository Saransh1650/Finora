import Foundation
import Supabase

class PortfolioRepo {
    static private let supabase = SupabaseManager.shared.client

    // Helper to get current user id
    static private var currentUserId: String? {
        (supabase.auth.currentUser?.id.uuidString)
    }

    static func fetchStocks() async -> ([StockModel]?, Failure?) {
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
            let response: [StockModel] = try await supabase.from("stocks")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            return (response, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: "Error fetching stocks",
                    errorType: ErrorType.fetchError
                )
            )
        }
    }

    static func addStock(
        _ stocks: [StockModel],
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
        // Ensure all stocks have the correct userId
        let userStocks = stocks.map { stock in
            var s = stock
            s.userId = userId
            return s
        }
        do {
            try await supabase.from("stocks")
                .insert(userStocks)
                .execute()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    static func updateStock(
        _ stock: StockModel,
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
        let stockId = stock.id.uuidString
        do {
            try await supabase.from("stocks")
                .update(stock)
                .eq("id", value: stockId)
                .eq("user_id", value: userId)
                .execute()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    static func deleteStocks(
        withId ids: [String],
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
            try await supabase.from("stocks")
                .delete()
                .in("id", values: ids)
                .eq("user_id", value: userId)
                .execute()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    static func deleteAllStocks(
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard let userId = currentUserId else {
            return
        }
        do {
            try await supabase.from("stocks")
                .delete()
                .eq("user_id", value: userId)
                .execute()
        } catch {
            print("Failed to delete all stocks: \(error)")
        }
    }
}
