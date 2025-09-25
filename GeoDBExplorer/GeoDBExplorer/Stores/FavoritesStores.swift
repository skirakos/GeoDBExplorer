//
//  FavoritesStores.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 25.09.25.
//

import Foundation

final class FavoriteCountriesStore {
    private let key = "fav"
    func load() -> [FavoriteCountry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([FavoriteCountry].self, from: data)
        else { return [] }
        return items
    }
    func save(_ items: [FavoriteCountry]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

final class FavoriteCitiesStore {
    private let key = "favCity"
    func load() -> [FavoriteCity] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([FavoriteCity].self, from: data)
        else { return [] }
        return items
    }
    func save(_ items: [FavoriteCity]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
