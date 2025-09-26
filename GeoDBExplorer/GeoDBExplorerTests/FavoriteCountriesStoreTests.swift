//
//  FavoriteCountriesStoreTests.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 24.09.25.
//

import Testing
import Foundation
@testable import GeoDBExplorer

@MainActor
final class FavoriteCountriesStoreTests {

    private func makeSuite(_ prefix: String = "tests.fav.countries")
    -> (name: String, ud: UserDefaults) {
        let name = "\(prefix).\(UUID().uuidString)"
        guard let ud = UserDefaults(suiteName: name) else { fatalError() }
        UserDefaults.standard.removePersistentDomain(forName: name)
        return (name, ud)
    }
    private func tearDown(_ name: String) {
        UserDefaults.standard.removePersistentDomain(forName: name)
    }

    @Test
    func fresh_store_loads_empty() {
        let (suite, ud) = makeSuite(); defer { tearDown(suite) }
        let store = FavoriteCountriesStore(userDefaults: ud)
        #expect(store.load().isEmpty)
    }

    @Test
    func save_then_load_round_trips() {
        let (suite, ud) = makeSuite(); defer { tearDown(suite) }
        let store = FavoriteCountriesStore(userDefaults: ud)
        let items = [FavoriteCountry.make(code: "AM"), FavoriteCountry.make(code: "FR", name: "France")]

        store.save(items)
        let loaded = store.load()

        #expect(loaded.count == 2)
        #expect(Set(loaded.map(\.code)) == ["AM","FR"])
    }

    @Test
    func persists_across_instances_in_same_suite() {
        let (suite, ud1) = makeSuite(); defer { tearDown(suite) }
        let a = FavoriteCountriesStore(userDefaults: ud1)
        a.save([.make(code: "DE", name: "Germany")])

        let ud2 = UserDefaults(suiteName: suite)!
        let b = FavoriteCountriesStore(userDefaults: ud2)

        #expect(b.load().map(\.code) == ["DE"])
    }

    @Test
    func save_overwrites_previous_value() {
        let (suite, ud) = makeSuite(); defer { tearDown(suite) }
        let store = FavoriteCountriesStore(userDefaults: ud)

        store.save([.make(code: "AM")])
        store.save([.make(code: "FR")])

        let loaded = store.load()
        #expect(loaded.count == 1)
        #expect(loaded.first?.code == "FR")
    }
}
