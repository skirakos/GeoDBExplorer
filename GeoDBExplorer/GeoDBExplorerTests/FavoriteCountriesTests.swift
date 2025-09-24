//
//  FavoriteCountriesTests.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 24.09.25.
//

import Testing
import Foundation
@testable import GeoDBExplorer

@MainActor
struct FavoriteCountriesTests {

    @Test
    func roundtrip_persists_and_loads() {
        UserDefaults.standard.removeObject(forKey: "fav")

        do {
            let favs = FavoriteCountries()
            let am = Country.make(code: "AM", name: "Armenia")
            favs.add(am)
            #expect(favs.favCountries.map(\.code) == ["AM"])
        }

        let favs2 = FavoriteCountries()
        #expect(favs2.favCountries.map(\.code) == ["AM"])

        UserDefaults.standard.removeObject(forKey: "fav")
    }
}

@MainActor
@Test
func add_is_idempotent() {
    UserDefaults.standard.removeObject(forKey: "fav")
    let favs = FavoriteCountries()

    let fr = Country.make(code: "FR", name: "France")
    favs.add(fr)
    favs.add(fr)

    #expect(favs.favCountries.count == 1)
    #expect(favs.favCountries.first?.code == "FR")

    UserDefaults.standard.removeObject(forKey: "fav")
}

@MainActor
@Test
func toggle_adds_then_removes() {
    UserDefaults.standard.removeObject(forKey: "fav")
    let favs = FavoriteCountries()
    let de = Country.make(code: "DE", name: "Germany")

    favs.toggle(de)
    #expect(favs.isFavorite("DE"))

    favs.toggle(de)
    #expect(!favs.isFavorite("DE"))

    UserDefaults.standard.removeObject(forKey: "fav")
}

@MainActor
@Test
func remove_nonexistent_returns_false_and_doesnt_change() {
    UserDefaults.standard.removeObject(forKey: "fav")
    let favs = FavoriteCountries()

    #expect(favs.favCountries.isEmpty)
    let removed = favs.remove("ZZ")
    #expect(removed == false)
    #expect(favs.favCountries.isEmpty)

    UserDefaults.standard.removeObject(forKey: "fav")
}

@MainActor
@Test
func remove_existing_returns_true_and_persists() {
    UserDefaults.standard.removeObject(forKey: "fav")
    let favs = FavoriteCountries()

    let fr = Country.make(code: "FR", name: "France")
    favs.add(fr)
    #expect(favs.isFavorite("FR"))

    let removed = favs.remove("FR")
    #expect(removed == true)
    #expect(!favs.isFavorite("FR"))

    let favs2 = FavoriteCountries()
    #expect(!favs2.isFavorite("FR"))

    UserDefaults.standard.removeObject(forKey: "fav")
}

@MainActor
@Test
func order_is_preserved_across_roundtrip() {
    UserDefaults.standard.removeObject(forKey: "fav")
    let favs = FavoriteCountries()

    let fr = Country.make(code: "FR", name: "France")
    let am = Country.make(code: "AM", name: "Armenia")
    favs.add(fr)
    favs.add(am)

    #expect(favs.favCountries.map(\.code) == ["FR","AM"])

    let favs2 = FavoriteCountries()
    #expect(favs2.favCountries.map(\.code) == ["FR","AM"])

    UserDefaults.standard.removeObject(forKey: "fav")
}
