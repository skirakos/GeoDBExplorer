//
//  Country.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 19.09.25.
//

import Foundation

struct Country: Decodable, Identifiable {
    var id: String { code }
    let code: String
    let name: String
    let wikiDataId: String?
    let region: String?
    let capital: String?
    let callingCode: String?
    let currencyCodes: [String]?
    let numRegions: Int?
    let flagImageUri: String?
}
