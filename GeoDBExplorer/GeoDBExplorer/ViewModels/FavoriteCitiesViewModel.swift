//
//  FavoriteCitiesViewModel.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 25.09.25.
//

import SwiftUI

@MainActor
final class FavoriteCitiesViewModel: ObservableObject {
    @Published private(set) var items: [FavoriteCity] = [] {
        didSet { store.save(items) }
    }
    private let store: FavoriteCitiesStore

    init(store: FavoriteCitiesStore) {
        self.store = store
        self.items = store.load()
    }

    func isFavorite(_ id: String) -> Bool {
        items.contains { $0.code == id }
    }

    func add(_ city: City) {
        guard !isFavorite(city.id) else { return }
        items.append(.init(code: city.id, name: city.name))
    }

    @discardableResult
    func remove(code: String) -> Bool {
        if let i = items.firstIndex(where: { $0.code == code }) {
            items.remove(at: i)
            return true
        }
        return false
    }

    func toggle(_ city: City) {
        isFavorite(city.id) ? _ = remove(code: city.id) : add(city)
    }
}
