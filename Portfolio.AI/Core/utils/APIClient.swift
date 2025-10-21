////
////  APIClient.swift
////  Portfolio.AI
////
////  Created by System on 18/10/25.
////
//
//import Foundation
//import Supabase
//
//protocol APIClientProtocol {
//    func request<T: Codable>(
//        endpoint: String,
//        method: HTTPMethod,
//        body: Data?,
//        responseType: T.Type
//    ) async throws -> T
//}
//
//enum HTTPMethod: String {
//    case GET = "GET"
//    case POST = "POST"
//    case PUT = "PUT"
//    case DELETE = "DELETE"
//}
//
//struct APIResponse<T: Codable>: Codable {
//    let success: Bool
//    let data: T?
//    let message: String?
//    let pagination: Pagination?
//}
//
//struct Pagination: Codable {
//    let page: Int
//    let limit: Int
//    let total: Int
//    let totalPages: Int
//}
//
//struct PaginatedAPIResponse<T: Codable>: Codable {
//    let success: Bool
//    let data: [T]
//    let pagination: Pagination?
//}
//
//class APIClient: APIClientProtocol {
//    static let shared = APIClient()
//
//    private let baseURL: String
//    private let supabase = SupabaseManager.shared.client
//
//    private init() {
//        self.baseURL = AppConfig.backendUrl
//    }
//
//    /// Get current access token from Supabase auth
//    private var accessToken: String? {
//        get async {
//            do {
//                let session = try await supabase.auth.session
//                return session.accessToken
//            } catch {
//                print("⚠️ APIClient: Failed to get access token: \(error)")
//                return nil
//            }
//        }
//    }
//
//    /// Make HTTP request to backend API
//    func request<T: Codable>(
//        endpoint: String,
//        method: HTTPMethod = .GET,
//        body: Data? = nil,
//        responseType: T.Type
//    ) async throws -> T {
//        guard let url = URL(string: "\(baseURL)/api/v1\(endpoint)") else {
//            throw APIError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // Add authorization header if user is authenticated
//        if let token = await accessToken {
//            request.setValue(
//                "Bearer \(token)",
//                forHTTPHeaderField: "Authorization"
//            )
//        }
//
//        if let body = body {
//            request.httpBody = body
//        }
//
//        do {
//            let (data, response) = try await URLSession.shared.data(
//                for: request
//            )
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle different status codes
//            switch httpResponse.statusCode {
//            case 200...299:
//                break
//            case 401:
//                throw APIError.unauthorized
//            case 404:
//                throw APIError.notFound
//            case 400...499:
//                throw APIError.clientError(httpResponse.statusCode)
//            case 500...599:
//                throw APIError.serverError(httpResponse.statusCode)
//            default:
//                throw APIError.unknownError(httpResponse.statusCode)
//            }
//
//            // Parse JSON response
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601
//
//            return try decoder.decode(T.self, from: data)
//
//        } catch let error as APIError {
//            throw error
//        } catch {
//            print("⚠️ APIClient: Network error: \(error)")
//            throw APIError.networkError(error)
//        }
//    }
//
//    /// Convenience method for GET requests
//    func get<T: Codable>(
//        endpoint: String,
//        responseType: T.Type
//    ) async throws -> T {
//        return try await request(
//            endpoint: endpoint,
//            method: .GET,
//            body: nil,
//            responseType: responseType
//        )
//    }
//
//    /// Convenience method for POST requests
//    func post<T: Codable, U: Codable>(
//        endpoint: String,
//        body: U,
//        responseType: T.Type
//    ) async throws -> T {
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        let bodyData = try encoder.encode(body)
//
//        return try await request(
//            endpoint: endpoint,
//            method: .POST,
//            body: bodyData,
//            responseType: responseType
//        )
//    }
//
//    /// Convenience method for PUT requests
//    func put<T: Codable, U: Codable>(
//        endpoint: String,
//        body: U,
//        responseType: T.Type
//    ) async throws -> T {
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        let bodyData = try encoder.encode(body)
//
//        return try await request(
//            endpoint: endpoint,
//            method: .PUT,
//            body: bodyData,
//            responseType: responseType
//        )
//    }
//
//    /// Convenience method for DELETE requests
//    func delete<T: Codable>(
//        endpoint: String,
//        responseType: T.Type
//    ) async throws -> T {
//        return try await request(
//            endpoint: endpoint,
//            method: .DELETE,
//            body: nil,
//            responseType: responseType
//        )
//    }
//
//    /// Convenience method for DELETE requests with body
//    func delete<T: Codable, U: Codable>(
//        endpoint: String,
//        body: U,
//        responseType: T.Type
//    ) async throws -> T {
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        let bodyData = try encoder.encode(body)
//
//        return try await request(
//            endpoint: endpoint,
//            method: .DELETE,
//            body: bodyData,
//            responseType: responseType
//        )
//    }
//}
//
///// API Error types
//enum APIError: Error, LocalizedError {
//    case invalidURL
//    case invalidResponse
//    case unauthorized
//    case notFound
//    case clientError(Int)
//    case serverError(Int)
//    case unknownError(Int)
//    case networkError(Error)
//    case decodingError(Error)
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "Invalid URL"
//        case .invalidResponse:
//            return "Invalid response"
//        case .unauthorized:
//            return "Unauthorized - Please log in again"
//        case .notFound:
//            return "Resource not found"
//        case .clientError(let code):
//            return "Client error: \(code)"
//        case .serverError(let code):
//            return "Server error: \(code)"
//        case .unknownError(let code):
//            return "Unknown error: \(code)"
//        case .networkError(let error):
//            return "Network error: \(error.localizedDescription)"
//        case .decodingError(let error):
//            return "Decoding error: \(error.localizedDescription)"
//        }
//    }
//}
//
///// Helper extension to convert APIError to Failure
//extension APIError {
//    func toFailure() -> Failure {
//        return Failure(
//            message: self.localizedDescription,
//            errorType: self.errorType
//        )
//    }
//
//    private var errorType: ErrorType {
//        switch self {
//        case .unauthorized:
//            return .authError
//        case .notFound:
//            return .fetchError
//        case .clientError, .serverError, .unknownError:
//            return .fetchError
//        case .networkError:
//            return .networkError
//        case .decodingError:
//            return .parseError
//        case .invalidURL, .invalidResponse:
//            return .unKnownError
//        }
//    }
//}
