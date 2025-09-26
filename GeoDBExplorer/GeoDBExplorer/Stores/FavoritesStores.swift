//
//  FavoritesStores.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 25.09.25.
//

import Foundation

final class FavoriteCountriesStore {
    private let key: String
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard, key: String = "fav") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func load() -> [FavoriteCountry] {
        guard
            let data = userDefaults.data(forKey: key),                // ← use injected UD
            let items = try? JSONDecoder().decode([FavoriteCountry].self, from: data)
        else { return [] }
        return items
    }

    func save(_ items: [FavoriteCountry]) {
        if let data = try? JSONEncoder().encode(items) {
            userDefaults.set(data, forKey: key)                       // ← use injected UD
        }
    }
}

final class FavoriteCitiesStore {
    private let key: String
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard, key: String = "favCity") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func load() -> [FavoriteCity] {
        guard
            let data = userDefaults.data(forKey: key),
            let items = try? JSONDecoder().decode([FavoriteCity].self, from: data)
        else { return [] }
        return items
    }

    func save(_ items: [FavoriteCity]) {
        if let data = try? JSONEncoder().encode(items) {
            userDefaults.set(data, forKey: key)
        }
    }
}
