//
//  CountryListViewModelTests.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 23.09.25.
//

import Testing
import Foundation
@testable import GeoDBExplorer

extension Country {
    static func make(code: String, name: String) -> Country {
        Country(code: code,
                name: name,
                wikiDataId: nil, region: nil, capital: nil,
                callingCode: nil, currencyCodes: nil,
                numRegions: nil, flagImageUri: nil)
    }
}

struct FakeGeoDBService: GeoDBServicing {
    let allCountries: [Country]
    var throwError: Bool
    
    init(allCountries: [Country] = [], throwError: Bool = false) {
        self.allCountries = allCountries
        self.throwError = throwError
    }
    
    func countries(limit: Int, offset: Int, language: String) async throws -> CountriesResponse {
        if throwError { throw URLError(.badServerResponse) }
        let page = Array(allCountries.dropFirst(offset).prefix(limit))
        return CountriesResponse(
            data: page,
            metadata: .init(totalCount: allCountries.count,
                            currentOffset: offset,
                            limit: page.count)
        )
    }

    func cities(countryCode: String, limit: Int, offset: Int, language: String) async throws -> CitiesResponse {
        fatalError("Not used in this test")
    }
}

@MainActor
struct CountryListViewModelTests {
    
    struct NoopService: GeoDBServicing {
        func countries(limit: Int, offset: Int, language: String) async throws -> GeoDBExplorer.CountriesResponse {
            throw URLError(.badServerResponse)
        }
        
        func cities(countryCode: String, limit: Int, offset: Int, language: String) async throws -> GeoDBExplorer.CitiesResponse {
            throw URLError(.badServerResponse)
        }
        
    }
    @Test
    func initial_state_is_empty() {
        let vm = CountryListViewModel(service: NoopService())
        
        #expect(vm.countries.isEmpty)
        #expect(vm.totalCount == 0)
        #expect(vm.page == 0)
        #expect(vm.isLoading == false)
        #expect(vm.canGoNext == false)
        #expect(vm.canGoPrev == false)
    }
    
    @Test
    func loads_first_page() async {
        let data = (1...9).map { i in Country.make(code: "C\(i)", name: "Country \(i)") }
        let service = FakeGeoDBService(allCountries: data)
        let vm = CountryListViewModel(service: service, pageSize: 4)

        vm.loadCountries()
        try? await Task.sleep(nanoseconds: 900_000_000)
        
        #expect(vm.isLoading == false)
        #expect(vm.totalCount == 9)
        #expect(vm.countries.count == 4)
        #expect(vm.countries.first?.name == "Country 1")
    }
    
    @Test
    func loads_second_page_after_next() async {
        let data = (1...9).map { i in Country.make(code: "C\(i)", name: "Country \(i)") }
        let service = FakeGeoDBService(allCountries: data)
        let vm = CountryListViewModel(service: service, pageSize: 4)

        vm.loadCountries()
        try? await Task.sleep(nanoseconds: 900_000_000)
        vm.nextPage()
        vm.loadCountries()
        try? await Task.sleep(nanoseconds: 900_000_000)

        #expect(vm.countries.map(\.name) == ["Country 5","Country 6","Country 7","Country 8"])
    }
    
    @MainActor
    @Test
    func last_page_disables_next() async {
        var fake = FakeGeoDBService(allCountries: (1...9).map { .make(code: "C\($0)", name: "Country \($0)") })
        let vm = CountryListViewModel(service: fake, pageSize: 4)

        vm.loadCountries()   // page 0
        try? await Task.sleep(nanoseconds: 900_000_000)
        vm.nextPage()              // page 1
        vm.loadCountries()
        try? await Task.sleep(nanoseconds: 900_000_000)
        vm.nextPage()              // page 2
        vm.loadCountries()   // last page (1 item)
        try? await Task.sleep(nanoseconds: 900_000_000)

        #expect(vm.page == 2)
        #expect(vm.countries.map(\.name) == ["Country 9"])
        #expect(vm.canGoNext == false)
        #expect(vm.canGoPrev == true)
    }
    
    
    @MainActor
    @Test
    func error_clears_data_and_sets_message() async {
        let fake = FakeGeoDBService(allCountries: [], throwError: true)
        let vm = CountryListViewModel(service: fake, pageSize: 4)

        vm.loadCountries()
        try? await Task.sleep(nanoseconds: 900_000_000)
        
        #expect(vm.countries.isEmpty)
        #expect(vm.totalCount == 0)
        #expect(vm.message.contains("error"))
    }
}

final class SpyService: GeoDBServicing {
    var lastLanguage = ""
    var countriesStub: [Country] = []

    func countries(limit: Int, offset: Int, language: String) async throws -> CountriesResponse {
        lastLanguage = language
        let page = Array(countriesStub.dropFirst(offset).prefix(limit))
        return .init(data: page, metadata: .init(totalCount: countriesStub.count, currentOffset: offset, limit: page.count))
    }
    func cities(countryCode: String, limit: Int, offset: Int, language: String) async throws -> CitiesResponse { fatalError() }
}

@MainActor
@Test
func prev_from_first_does_nothing() async {
    let data = (1...5).map { Country.make(code: "C\($0)", name: "Country \($0)") }
    let vm = CountryListViewModel(service: FakeGeoDBService(allCountries: data), pageSize: 2)

    vm.loadCountries()
    try? await Task.sleep(nanoseconds: 1_100_000_000)

    #expect(vm.page == 0)
    vm.prevPage()
    // No load triggered—still page 0
    #expect(vm.page == 0)
}

@MainActor
@Test
func next_from_last_does_nothing() async {
    let data = (1...5).map { Country.make(code: "C\($0)", name: "Country \($0)") }
    let vm = CountryListViewModel(service: FakeGeoDBService(allCountries: data), pageSize: 2)

    vm.loadCountries()
    try? await Task.sleep(nanoseconds: 1_100_000_000)
    vm.nextPage(); vm.loadCountries()
    try? await Task.sleep(nanoseconds: 1_100_000_000)
    vm.nextPage(); vm.loadCountries()
    try? await Task.sleep(nanoseconds: 1_100_000_000)

    #expect(vm.page == 2)
    vm.nextPage()
    #expect(vm.page == 2)
}
