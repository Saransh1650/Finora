//
//  ChatRepoExtension.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 26/9/25.
//

import Foundation


extension ChatRepo {
    /// Check if error is a "Message too long" network error
    static func isMessageTooLongError(_ error: Error) -> Bool {
        if let nsError = error as? NSError {
            let isMessageTooLong = nsError.domain == NSPOSIXErrorDomain && nsError.code == 40
            if isMessageTooLong {
                print("🔴 ChatRepo Debug: Detected Message Too Long Error - Domain: \(nsError.domain), Code: \(nsError.code)")
                print("🔴 ChatRepo Debug: Full error info: \(nsError)")
            }
            return isMessageTooLong
        }
        return false
    }
    
    /// Check if error is any kind of network/connection error that should be retried
    static func shouldRetryError(_ error: Error) -> Bool {
        // Check for message too long
        if isMessageTooLongError(error) {
            return true
        }
        
        // Check for other transient network errors
        if let nsError = error as? NSError {
            // URLError codes that are worth retrying
            let retryableURLErrorCodes = [
                NSURLErrorTimedOut,
                NSURLErrorCannotConnectToHost,
                NSURLErrorNetworkConnectionLost,
                NSURLErrorNotConnectedToInternet,
                NSURLErrorDNSLookupFailed
            ]
            
            if nsError.domain == NSURLErrorDomain && retryableURLErrorCodes.contains(nsError.code) {
                print("🟡 ChatRepo Debug: Detected retryable URL error - Code: \(nsError.code)")
                return true
            }
        }
        
        return false
    }
    
    /// Perform operation with retry logic for network errors
    static func withRetry<T>(
        maxRetries: Int = 2,
        operation: () async throws -> T
    ) async -> Result<T, Error> {
        var retryCount = 0
        
        while retryCount < maxRetries {
            do {
                let result = try await operation()
                if retryCount > 0 {
                    print("🟢 ChatRepo Debug: Operation succeeded after \(retryCount) retries")
                }
                return .success(result)
            } catch {
                print("🔴 ChatRepo Debug: Attempt \(retryCount + 1) failed with error: \(error)")
                
                if shouldRetryError(error) {
                    print("🟡 ChatRepo Debug: Error is retryable, attempting retry...")
                    retryCount += 1
                    
                    if retryCount < maxRetries {
                        // Exponential backoff with jitter
                        let baseDelay = Double(retryCount) * 0.5
                        let jitter = Double.random(in: 0...0.2)
                        let delay = baseDelay + jitter
                        print("🟡 ChatRepo Debug: Waiting \(delay)s before retry \(retryCount + 1)")
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    } else {
                        print("🔴 ChatRepo Debug: Max retries (\(maxRetries)) reached")
                    }
                } else {
                    print("🔴 ChatRepo Debug: Error is not retryable, failing immediately")
                }
                
                return .failure(error)
            }
        }
        
        return .failure(NSError(domain: "ChatRepo", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Failed after \(maxRetries) attempts"
        ]))
    }
}
