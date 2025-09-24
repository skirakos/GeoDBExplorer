//
//  City.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 19.09.25.
//

import Foundation

struct City: Decodable, Identifiable {
    var id: String { wikiDataId ?? "\(name)-\(latitude)-\(longitude)" }
    let name: String
    let wikiDataId: String?
    let countryCode: String?
    let region: String?
    let latitude: Double
    let longitude: Double
    let population: Int?
}
