//
//  FavoriteCountriesViewModel.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 25.09.25.
//

import SwiftUI

@MainActor
final class FavoriteCountriesViewModel: ObservableObject {
    @Published private(set) var items: [FavoriteCountry] = [] {
        didSet { store.save(items) }
    }
    private let store: FavoriteCountriesStore

    init(store: FavoriteCountriesStore) {
        self.store = store
        self.items = store.load()
    }

    func isFavorite(_ code: String) -> Bool {
        items.contains { $0.code == code }
    }

    func add(_ country: Country) {
        guard !isFavorite(country.code) else { return }
        items.append(.init(code: country.code, name: country.name))
    }

    @discardableResult
    func remove(code: String) -> Bool {
        if let i = items.firstIndex(where: { $0.code == code }) {
            items.remove(at: i)
            return true
        }
        return false
    }

    func toggle(_ country: Country) {
        isFavorite(country.code) ? _ = remove(code: country.code) : add(country)
    }
}
