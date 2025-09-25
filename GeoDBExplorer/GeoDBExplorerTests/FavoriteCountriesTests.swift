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
struct FavoriteCountriesViewModelTests {

    private func reset() { UserDefaults.standard.removeObject(forKey: "fav") }

    @Test
    func roundtrip_persists_and_loads() {
        reset()

        do {
            let vm = FavoriteCountriesViewModel(store: FavoriteCountriesStore())
            vm.add(.make(code: "AM", name: "Armenia"))
            #expect(vm.items.map(\.code) == ["AM"])
        }
        let vm2 = FavoriteCountriesViewModel(store: FavoriteCountriesStore())
        #expect(vm2.items.map(\.code) == ["AM"])

        reset()
    }

    @Test
    func add_is_idempotent() {
        reset()
        let vm = FavoriteCountriesViewModel(store: FavoriteCountriesStore())

        let fr = Country.make(code: "FR", name: "France")
        vm.add(fr)
        vm.add(fr)

        #expect(vm.items.count == 1)
        #expect(vm.items.first?.code == "FR")

        reset()
    }

    @Test
    func toggle_adds_then_removes() {
        reset()
        let vm = FavoriteCountriesViewModel(store: FavoriteCountriesStore())
        let de = Country.make(code: "DE", name: "Germany")

        vm.toggle(de)
        #expect(vm.isFavorite("DE"))

        vm.toggle(de)
        #expect(!vm.isFavorite("DE"))

        reset()
    }

    @Test
    func remove_nonexistent_returns_false_and_doesnt_change() {
        reset()
        let vm = FavoriteCountriesViewModel(store: FavoriteCountriesStore())

        #expect(vm.items.isEmpty)
        let removed = vm.remove(code: "ZZ")
        #expect(removed == false)
        #expect(vm.items.isEmpty)

        reset()
    }

    @Test
    func remove_existing_returns_true_and_persists() {
        reset()
        let vm = FavoriteCountriesViewModel(store: FavoriteCountriesStore())

        let fr = Country.make(code: "FR", name: "France")
        vm.add(fr)
        #expect(vm.isFavorite("FR"))

        let removed = vm.remove(code: "FR")
        #expect(removed == true)
        #expect(!vm.isFavorite("FR"))

        let vm2 = FavoriteCountriesViewModel(store: FavoriteCountriesStore())
        #expect(!vm2.isFavorite("FR"))

        reset()
    }

    @Test
    func order_is_preserved_across_roundtrip() {
        reset()
        let vm = FavoriteCountriesViewModel(store: FavoriteCountriesStore())

        let fr = Country.make(code: "FR", name: "France")
        let am = Country.make(code: "AM", name: "Armenia")
        vm.add(fr)
        vm.add(am)

        #expect(vm.items.map(\.code) == ["FR","AM"])

        let vm2 = FavoriteCountriesViewModel(store: FavoriteCountriesStore())
        #expect(vm2.items.map(\.code) == ["FR","AM"])

        reset()
    }
}
