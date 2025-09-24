//
//  FavoriteCities.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 20.09.25.
//

import SwiftUI

@MainActor
class FavoriteCities: ObservableObject { //final?
    @Published var favCities: [FavoriteCity] = [] {
        didSet { keep() }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "favCity"),
           let items = try? JSONDecoder().decode([FavoriteCity].self, from: data) {
            self.favCities = items
        }
    }

    func isFavorite(_ code: String) -> Bool {
        favCities.contains { $0.code == code }
    }
    
    func add(_ city: City) {
        guard !isFavorite(city.id) else { return }
        favCities.append(.init(code: city.id, name: city.name))
    }
    
    func remove(_ code: String) -> Bool {
        if let i = favCities.firstIndex(where: { $0.code == code }) {
            favCities.remove(at: i)
            return true
        } else {
            return false
        }
    }
    
    func toggle(_ city: City) {
        isFavorite(city.id) ? _ = remove(city.id) : add(city)
    }
    
    private func keep() {
        if let data = try? JSONEncoder().encode(favCities) {
            UserDefaults.standard.set(data, forKey: "favCity")
        }
    }
}
