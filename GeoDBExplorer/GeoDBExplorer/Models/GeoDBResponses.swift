//
//  GeoDBResponses..swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 19.09.25.
//

struct CountriesResponse: Decodable {
    let data: [Country]
    let metadata: Metadata

    struct Metadata: Decodable {
        let totalCount: Int
        let currentOffset: Int
        let limit: Int?
    }
}

struct CitiesResponse: Decodable {
    let data: [City]
    let metadata: CountriesResponse.Metadata
}
