//
//  DummyService.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 26.09.25.
//

@testable import GeoDBExplorer

struct DummyGeoDBService: GeoDBServicing {
    func countries(limit: Int, offset: Int, language: String) async throws -> CountriesResponse {
        .init(data: [], metadata: .init(totalCount: 0, currentOffset: 0, limit: 0))
    }
    func cities(countryCode: String, limit: Int, offset: Int, language: String) async throws -> CitiesResponse {
        .init(data: [], metadata: .init(totalCount: 0, currentOffset: 0, limit: 0))
    }
}
