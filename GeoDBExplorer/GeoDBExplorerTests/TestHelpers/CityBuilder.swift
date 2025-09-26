//
//  CityBuilder.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 26.09.25.
//

@testable import GeoDBExplorer

@testable import GeoDBExplorer

extension City {
    static func make(
        name: String = "Yerevan",
        countryCode: String? = "AM",
        region: String? = nil,
        latitude: Double = 40.18,
        longitude: Double = 44.51,
        population: Int? = nil,
        wikiDataId: String? = "Q399"
    ) -> City {
        City(
            name: name,
            wikiDataId: wikiDataId,
            countryCode: countryCode,
            region: region,
            latitude: latitude,
            longitude: longitude,
            population: population
        )
    }
}

extension CitiesResponse {
    static func make(
        data: [City],
        total: Int,
        offset: Int,
        limit: Int
    ) -> CitiesResponse {
        .init(
            data: data,
            metadata: .init(totalCount: total, currentOffset: offset, limit: limit)
        )
    }
}
