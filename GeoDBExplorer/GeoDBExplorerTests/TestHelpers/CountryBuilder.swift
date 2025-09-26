//
//  CountryBuilder.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 26.09.25.
//

@testable import GeoDBExplorer

extension Country {
    static func make(
        code: String = "AM",
        name: String = "Armenia",
        wikiDataId: String? = nil,
        region: String? = nil,
        capital: String? = nil,
        callingCode: String? = nil,
        currencyCodes: [String]? = nil,
        numRegions: Int? = nil,
        flagImageUri: String? = nil
    ) -> Country {
        .init(code: code,
              name: name,
              wikiDataId: wikiDataId,
              region: region,
              capital: capital,
              callingCode: callingCode,
              currencyCodes: currencyCodes,
              numRegions: numRegions,
              flagImageUri: flagImageUri)
    }
}
