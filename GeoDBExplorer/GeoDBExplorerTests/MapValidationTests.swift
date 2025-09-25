//
//  MapValidationTests.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 24.09.25.
//

// MapValidationTests.swift
import Testing
@testable import GeoDBExplorer

// A no-op service so we can construct the VM
private struct DummyService: GeoDBServicing {
    func countries(limit: Int, offset: Int, language: String) async throws -> CountriesResponse {
        .init(data: [], metadata: .init(totalCount: 0, currentOffset: 0, limit: 0))
    }
    func cities(countryCode: String, limit: Int, offset: Int, language: String) async throws -> CitiesResponse {
        .init(data: [], metadata: .init(totalCount: 0, currentOffset: 0, limit: 0))
    }
}

@MainActor
struct MapValidationTests {

    private func makeVM() -> CityListViewModel {
        CityListViewModel(
            country: .make(code: "AM", name: "Armenia"),
            service: DummyService(),
            pageSize: 1,
            throttleInterval: 0 // <- important for tests
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
