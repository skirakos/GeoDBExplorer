//
//  FavoriteBuilders.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 26.09.25.
//

@testable import GeoDBExplorer

extension FavoriteCountry {
    static func make(code: String = "AM", name: String = "Armenia") -> FavoriteCountry {
        .init(code: code, name: name)
    }
}
extension FavoriteCity {
    static func make(code: String = "EVN", name: String = "Yerevan") -> FavoriteCity {
        .init(code: code, name: name)
    }
}
