import Foundation

final class Api {
    static let shared = Api()
    private let session = URLSession.shared
    private init() {}

    func sendRequest(
        path: String,
        method: MethodType,
        requestType: RequestType = .json,
        host: String? = nil,
        body: [String: Any]? = nil,
        multipartBody: MultipartBody? = nil,
        headers: [String: String]? = nil,
        queryParameters: [String: Any]? = nil,
        retry: Int = 0,
        doesRequireAuth: Bool = true
    ) async -> (Any?, Failure?) {
        var finalHeaders = headers ?? [:]
        let finalQueryParams = queryParameters ?? [:]

        let hostValue = host ?? AppConfig.backendUrl
        let accessToken: String? = LocalStorage.getString(
            LocalStorageKeys.accessToken
        )
        print("url: \(hostValue)\(path)")
        // Add Authorization header if needed
        if doesRequireAuth,
            finalHeaders["Authorization"] == nil,
            let token = accessToken
        {
            finalHeaders["Authorization"] = "Bearer \(token)"
        }

        // Add content-type headers
        switch requestType {
        case .json:
            finalHeaders["Accept"] = "application/json"
            finalHeaders["Content-Type"] = "application/json"
        case .multipart:
            finalHeaders["Accept"] = "application/json"
        }

        // Build URL
        var urlComponents = URLComponents()
        urlComponents.scheme = AppConstants.scheme
        urlComponents.host = hostValue
        urlComponents.path = "/api/v1\(path)"
        if !finalQueryParams.isEmpty {
            urlComponents.queryItems = finalQueryParams.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        print("scheme:\(AppConstants.scheme)")
        print("host:\(hostValue)")
        print("path:\(path)")
        guard let url = urlComponents.url else {
            return (
                nil, Failure(message: "Invalid URL", errorType: .unKnownError)
            )
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = finalHeaders

        // Body
        if requestType == .json, let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        if requestType == .multipart, let multipartBody = multipartBody {
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue(
                "multipart/form-data; boundary=\(boundary)",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = multipartBody.toData(boundary: boundary)
        }
        
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return (
                    nil,
                    Failure(
                        message: "Invalid response",
                        errorType: .unKnownError
                    )
                )
            }

            switch httpResponse.statusCode {
            case 200, 201:
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    return (json, nil)
                } catch {
                    return (
                        nil,
                        Failure(
                            message: "JSON parse error",
                            errorType: .unKnownError
                        )
                    )
                }

            case 400:
                return (
                    nil,
                    Failure(
                        message: extractMessage(from: data),
                        errorType: .invalidInput
                    )
                )

            case 401:
                if method == .delete {
                    return (nil, nil)
                }
                // MARK: Add refresh token logic here if needed
                return (
                    nil,
                    Failure(
                        message: ErrorType.unAuthorized.message,
                        errorType: .unAuthorized
                    )
                )

            case 404:
                return (
                    nil,
                    Failure(
                        message: extractMessage(from: data) ?? "Not found",
                        errorType: .notFound
                    )
                )

            case 409:
                return (
                    nil,
                    Failure(
                        message: extractMessage(from: data),
                        errorType: .conflict
                    )
                )

            case 429:
                return (
                    nil,
                    Failure(
                        message: "Too many requests. Try again later.",
                        errorType: .tooManyRequests
                    )
                )

            case 500:
                return (
                    nil,
                    Failure(
                        message: extractMessage(from: data),
                        errorType: .serverError
                    )
                )

            default:
                return (
                    nil,
                    Failure(
                        message: extractMessage(from: data) ?? "Unknown error",
                        errorType: .unKnownError
                    )
                )
            }

        } catch let error as URLError {
            return (
                nil,
                Failure(
                    message: error.localizedDescription,
                    errorType: .networkError
                )
            )
        } catch {
            return (
                nil,
                Failure(
                    message: "Unexpected error: \(error.localizedDescription)",
                    errorType: .unKnownError
                )
            )
        }
    }

    private func extractMessage(from data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data)
            as? [String: Any],
            let message = json["message"] as? String
        {
            return message
        }
        return nil
    }
}
