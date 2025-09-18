import Foundation

class Api {
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
        doesRequireAuth: Bool = true,
        completion: @escaping (Any?, Failure?) -> Void
    ) {
        var finalHeaders = headers ?? [:]
        let finalQueryParams = queryParameters ?? [:]
        
        let hostValue = host ?? ""
        let accessToken: String? = LocalStorage.getString(LocalStorageKeys.accessToken)
        
        if doesRequireAuth, finalHeaders["Authorization"] == nil, let token = accessToken {
            finalHeaders["Authorization"] = "Bearer \(token)"
        }
        
        
        switch requestType {
            case .json:
                finalHeaders["Accept"] = "application/json"
                finalHeaders["Content-Type"] = "application/json"
            case .multipart:
                finalHeaders["Accept"] = "application/json"
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = AppConstants.scheme
        urlComponents.host = hostValue
        urlComponents.path = path
        if !finalQueryParams.isEmpty {
            urlComponents.queryItems = finalQueryParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        guard let url = urlComponents.url else {
            completion(nil, Failure(message: "Invalid URL", errorType: .unKnownError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = finalHeaders
        
        if requestType == .json, let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        if requestType == .multipart, let multipartBody = multipartBody {
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = multipartBody.toData(boundary: boundary)
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error as? URLError {
                completion(nil, Failure(message: error.localizedDescription, errorType: .unKnownError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, Failure(message: "Invalid response", errorType: .unKnownError))
                return
            }
            
            guard let data = data else {
                completion(nil, Failure(message: "No data", errorType: .unKnownError))
                return
            }
            
            switch httpResponse.statusCode {
                case 200, 201:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        completion(json, nil)
                    } catch {
                        completion(nil, Failure(message: "JSON parse error", errorType: .unKnownError))
                    }
                case 400:
                    completion(nil, Failure(message: self.extractMessage(from: data), errorType: .invalidInput))
                case 401:
                    if method == .delete {
                        completion(nil, nil)
                        return
                    }
                    // MARK: Refresh token logic
                    completion(nil, Failure(message: ErrorType.unAuthorized.message, errorType: .unAuthorized))
                case 404:
                    completion(nil, Failure(message: self.extractMessage(from: data) ?? "Not found", errorType: .notFound))
                case 409:
                    completion(nil, Failure(message: self.extractMessage(from: data), errorType: .conflict))
                case 429:
                    completion(nil, Failure(message: "Too many requests. Try again later.", errorType: .tooManyRequests))
                case 500:
                    completion(nil, Failure(message: self.extractMessage(from: data), errorType: .serverError))
                default:
                    completion(nil, Failure(message: self.extractMessage(from: data) ?? "Unknown error", errorType: .unKnownError))
            }
        }
        
        task.resume()
    }
    
    private func extractMessage(from data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["message"] as? String {
            return message
        }
        return nil
    }
}
