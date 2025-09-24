//
//  GeoDBService.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 19.09.25.
//

import Foundation

protocol GeoDBServicing {
    func countries(limit: Int, offset: Int, language: String) async throws -> CountriesResponse
    func cities(countryCode: String, limit: Int, offset: Int, language: String) async throws -> CitiesResponse
}

final class GeoDBServiceLive: GeoDBServicing {
    private let session: URLSession = .shared
    private let apiKey: String
    private let host = "wft-geo-db.p.rapidapi.com"
    private let base = "https://wft-geo-db.p.rapidapi.com"
    
//    let rapidAPIKey = "f5f94d4850msh98f4b69b5c51ee0p1ee57ejsn78cb557e5f6a"

    init(apiKey: String) { self.apiKey = apiKey }

    private func request(path: String, _ query: [URLQueryItem]) throws -> URLRequest {
        var comps = URLComponents(string: base + path)!
        comps.queryItems = query
        var req = URLRequest(url: comps.url!)
        req.httpMethod = "GET"
        req.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        req.setValue(host, forHTTPHeaderField: "X-RapidAPI-Host")
        return req
    }

    private func fetch<T: Decodable>(_ req: URLRequest) async throws -> T {
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func countries(limit: Int, offset: Int, language: String) async throws -> CountriesResponse {
        let req = try request(path: "/v1/geo/countries", [
            .init(name: "limit", value: "\(limit)"),
            .init(name: "offset", value: "\(offset)"),
            .init(name: "languageCode", value: language)
        ])
        return try await fetch(req)
    }

    func cities(countryCode: String, limit: Int, offset: Int, language: String) async throws -> CitiesResponse {
        let req = try request(path: "/v1/geo/cities", [
            .init(name: "countryIds", value: countryCode),
            .init(name: "types", value: "CITY"),
            .init(name: "limit", value: "\(limit)"),
            .init(name: "offset", value: "\(offset)"),
            .init(name: "languageCode", value: language)
        ])
        return try await fetch(req)
    }
}
