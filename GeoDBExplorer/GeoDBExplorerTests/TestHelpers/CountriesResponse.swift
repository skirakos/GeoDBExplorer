//
//  CountriesResponse.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 26.09.25.
//

@testable import GeoDBExplorer

extension CountriesResponse {
    static func make(
        data: [Country],
        total: Int,
        offset: Int,
        limit: Int
    ) -> CountriesResponse {
        .init(
            data: data,
            metadata: .init(totalCount: total, currentOffset: offset, limit: limit)
        )
    }
}
