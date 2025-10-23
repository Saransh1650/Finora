import Foundation
import Supabase

class PortfolioRepo {
    private static let apiClient = Api.shared
    private static let supabase = SupabaseManager.shared.client

    // Helper to get current user id
    static private var currentUserId: String? {
        (supabase.auth.currentUser?.id.uuidString)
    }

    static func fetchStocks() async -> ([StockModel]?, Failure?) {
        guard let _ = currentUserId else {
            return (
                nil,
                Failure(
                    message: "User not authenticated",
                    errorType: ErrorType.fetchError
                )
            )
        }
        
        let (result, error) = await apiClient.sendRequest(
            path: AppEndpoints.stocks,
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
            let stocks = try JSONDecoder().decode([StockModel].self, from: jsonData)
            return (stocks, nil)
        } catch {
            return (
                nil,
                Failure(
                    message: "Error parsing stocks: \(error.localizedDescription)",
                    errorType: ErrorType.parseError
                )
            )
        }
    }

    static func addStock(
        _ stocks: [StockModel],
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard let _ = currentUserId else {
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
        
        let endpoint = stocks.count == 1 ? AppEndpoints.stocks : AppEndpoints.bulkStocks
        let body = stocks.count == 1 ?
            try? stocks[0].toDictionary() : 
            ["stocks": try! stocks.map { try $0.toDictionary() }]
        
        let (_, error) = await apiClient.sendRequest(
            path: endpoint,
            method: .post,
            body: body
        )
        
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }

    static func updateStock(
        _ stock: StockModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard let _ = currentUserId else {
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
        let (_, error) = await apiClient.sendRequest(
            path: AppEndpoints.stock(id: stockId),
            method: .put,
            body: try? stock.toDictionary()
        )
        
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }

    static func deleteStocks(
        withId ids: [String],
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard let _ = currentUserId else {
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
        
        let (endpoint, body): (String, [String: Any]?) = {
            if ids.count == 1 {
                return (AppEndpoints.stock(id: ids[0]), nil)
            } else {
                return (AppEndpoints.bulkStocks, ["ids": ids])
            }
        }()
        
        let (_, error) = await apiClient.sendRequest(
            path: endpoint,
            method: .delete,
            body: body
        )
        
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }

    static func deleteAllStocks(
        completion: @escaping (Result<Void, Error>) -> Void
    ) async {
        guard let _ = currentUserId else {
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
        
        // First fetch all stocks to get their IDs
        let (fetchResult, fetchError) = await apiClient.sendRequest(
            path: AppEndpoints.stocks,
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
            completion(.success(())) // No stocks to delete
            return
        }
        
        if dataArray.isEmpty {
            completion(.success(()))
            return
        }
        
        let stockIds = dataArray.compactMap { $0["id"] as? String }
        
        let (_, deleteError) = await apiClient.sendRequest(
            path: AppEndpoints.bulkStocks,
            method: .delete,
            body: ["ids": stockIds]
        )
        
        if let deleteError = deleteError {
            completion(.failure(deleteError))
        } else {
            completion(.success(()))
        }
    }
}
