import Foundation
import Supabase

class PortfolioRepo {
    static private let supabase = SupabaseManager.shared.client
    
    static func fetchStocks() async -> ([StockModel]?, Failure?) {
        do {
            let response: [StockModel] = try await supabase.from("stocks")
                .select()
                .execute()
                .value
            return (response, nil)
        } catch {
            return (nil, Failure(message: "Error fetching stocks", errorType: ErrorType.fetchError))
        }
    }

    static func addStock(
        _ stocks: [StockModel],
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        do {
            try await supabase.from("stocks")
                .insert(stocks)
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
        do {
            let stockId = stock.id.uuidString
            try await supabase.from("stocks")
                .update(stock)
                .eq("id", value: stockId)
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
        do {
            try await supabase.from("stocks")
                .delete()
                .in("id", values: ids)
                .execute()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    
}
