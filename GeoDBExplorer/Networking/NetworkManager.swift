//
//  NetworkManager.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 25.09.25.
//

import Foundation

struct RetryPolicy {
    let maxAttempts: Int
    let baseDelay: TimeInterval
    static let oneRetry = RetryPolicy(maxAttempts: 2, baseDelay: 0.7)
}

final class NetworkManager {
    private let baseURL: URL
    private let apiKey: String
    private let hostHeader: String
    private let session: URLSession
    private let retry: RetryPolicy

    init(baseURL: URL,
         apiKey: String,
         hostHeader: String,
         retry: RetryPolicy = .oneRetry,
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.hostHeader = hostHeader
        self.retry = retry
        self.session = session
    }

    func send<R: APIRequest>(_ request: R) async throws -> R.Response {
        var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        comps.path = request.path
        comps.queryItems = request.query.isEmpty ? nil : request.query
        guard let url = comps.url else { throw URLError(.badURL) }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        urlRequest.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        urlRequest.setValue(hostHeader, forHTTPHeaderField: "X-RapidAPI-Host")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        var lastError: Error?
        for attempt in 1...retry.maxAttempts {
            do {
                let (data, resp) = try await session.data(for: urlRequest)
                guard let http = resp as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                if http.statusCode == 429, attempt < retry.maxAttempts {
                    let retryAfter = http.value(forHTTPHeaderField: "Retry-After")
                        .flatMap(TimeInterval.init) ?? retry.baseDelay
                    try? await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
                    continue
                }

                guard (200..<300).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }

                return try JSONDecoder().decode(R.Response.self, from: data)
            } catch {
                lastError = error
                if attempt < retry.maxAttempts {
                    try? await Task.sleep(nanoseconds: UInt64(retry.baseDelay * 1_000_000_000))
                    continue
                }
            }
        }
        throw lastError ?? URLError(.cannotLoadFromNetwork)
    }
}
