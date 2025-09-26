//
//  MapValidationTests.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 24.09.25.
//

import Testing
@testable import GeoDBExplorer


@MainActor
struct MapValidationTests {

    private func makeVM() -> CityListViewModel {
        CityListViewModel(
            country: .make(code: "AM", name: "Armenia"),
            service: DummyGeoDBService(),
            pageSize: 1,
            throttleInterval: 0
        )
    }

    @Test func accepts_valid_coords() {
        let vm = makeVM()
        #expect(vm.isValidCoordinate(lat: 40.18, lon: 44.51))
    }

    @Test func rejects_bad_lat() {
        let vm = makeVM()
        #expect(!vm.isValidCoordinate(lat: 123, lon: 44.5))
    }

    @Test func rejects_bad_lon() {
        let vm = makeVM()
        #expect(!vm.isValidCoordinate(lat: 40, lon: 200))
    }

    @Test func rejects_nan_or_infinity() {
        let vm = makeVM()
        #expect(!vm.isValidCoordinate(lat: .infinity, lon: 0))
        #expect(!vm.isValidCoordinate(lat: .nan,       lon: 0))
    }
}
