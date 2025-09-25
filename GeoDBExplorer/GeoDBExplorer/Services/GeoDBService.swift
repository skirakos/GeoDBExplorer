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

struct CountriesRequest: APIRequest {
    typealias Response = CountriesResponse
    let limit: Int
    let offset: Int
    let language: String

    var path: String { "/v1/geo/countries" }
    var query: [URLQueryItem] {
        [
            .init(name: "limit", value: "\(limit)"),
            .init(name: "offset", value: "\(offset)"),
            .init(name: "languageCode", value: language)
        ]
    }
}

struct CitiesRequest: APIRequest {
    typealias Response = CitiesResponse
    let countryCode: String
    let limit: Int
    let offset: Int
    let language: String

    var path: String { "/v1/geo/cities" }
    var query: [URLQueryItem] {
        [
            .init(name: "countryIds", value: countryCode),
            .init(name: "types", value: "CITY"),
            .init(name: "limit", value: "\(limit)"),
            .init(name: "offset", value: "\(offset)"),
            .init(name: "languageCode", value: language)
        ]
    }
}

final class GeoDBService: GeoDBServicing {
    private let network: NetworkManager
    init(network: NetworkManager) { self.network = network }

    func countries(limit: Int, offset: Int, language: String) async throws -> CountriesResponse {
        try await network.send(CountriesRequest(limit: limit, offset: offset, language: language))
    }

    func cities(countryCode: String, limit: Int, offset: Int, language: String) async throws -> CitiesResponse {
        try await network.send(CitiesRequest(countryCode: countryCode, limit: limit, offset: offset, language: language))
    }
}
