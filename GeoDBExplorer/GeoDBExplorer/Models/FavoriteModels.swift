//
//  FavoriteModels.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 20.09.25.
//

import Foundation

struct FavoriteCity: Identifiable, Codable, Hashable {
    var id: String { code }
    let code: String
    let name: String
}


struct FavoriteCountry: Identifiable, Codable, Hashable {
    var id: String { code }
    let code: String
    let name: String
}
