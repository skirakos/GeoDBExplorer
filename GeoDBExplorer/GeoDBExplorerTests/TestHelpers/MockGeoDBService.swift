//
//  MockGeoDBService.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 26.09.25.
//

@testable import GeoDBExplorer

final class MockGeoDBService: GeoDBServicing {
    var nextCountries: Result<CountriesResponse, Error> = .success(
        .init(data: [], metadata: .init(totalCount: 0, currentOffset: 0, limit: 0))
    )
    var nextCities: Result<CitiesResponse, Error> = .success(
        .init(data: [], metadata: .init(totalCount: 0, currentOffset: 0, limit: 0))
    )

    private(set) var countriesCalls: [(limit: Int, offset: Int, language: String)] = []
    private(set) var citiesCalls: [(countryCode: String, limit: Int, offset: Int, language: String)] = []

    func countries(limit: Int, offset: Int, language: String) async throws -> CountriesResponse {
        countriesCalls.append((limit, offset, language))
        return try nextCountries.get()
    }

    func cities(countryCode: String, limit: Int, offset: Int, language: String) async throws -> CitiesResponse {
        citiesCalls.append((countryCode, limit, offset, language))
        return try nextCities.get()
    }
}
