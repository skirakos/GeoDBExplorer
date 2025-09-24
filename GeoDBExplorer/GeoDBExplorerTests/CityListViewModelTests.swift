//
//  CityListViewModelTests.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 24.09.25.
//

import Testing
import Foundation
@testable import GeoDBExplorer


extension City {
    static func make(
        name: String,
        countryCode: String,
        region: String? = nil,
        lat: Double = 40.18,
        lon: Double = 44.51,
        population: Int? = nil,
        wikiDataId: String? = nil
    ) -> City {
        City(
            name: name,
            wikiDataId: wikiDataId,
            countryCode: countryCode,
            region: region,
            latitude: lat,
            longitude: lon,
            population: population
        )
    }
}

struct FakeCityService: GeoDBServicing {
    var citiesByCountry: [String: [City]] = [:]
    var throwCitiesError = false

    func countries(limit: Int, offset: Int, language: String) async throws -> CountriesResponse {
        fatalError("countries() not used in CityListViewModel tests")
    }

    func cities(countryCode: String, limit: Int, offset: Int, language: String) async throws -> CitiesResponse {
        if throwCitiesError { throw URLError(.badServerResponse) }
        let all = citiesByCountry[countryCode] ?? []
        let page = Array(all.dropFirst(offset).prefix(limit))
        return CitiesResponse(
            data: page,
            metadata: CountriesResponse.Metadata(
                totalCount: all.count,
                currentOffset: offset,
                limit: page.count
            )
        )
    }
}

// MARK: - Tests

@MainActor
struct CityListViewModelTests {

    @Test
    func initial_state_is_empty() {
        let am = Country.make(code: "AM", name: "Armenia")
        let vm = CityListViewModel(country: am, service: FakeCityService(), pageSize: 3)

        #expect(vm.cities.isEmpty)
        #expect(vm.totalCount == 0)
        #expect(vm.page == 0)
        #expect(vm.isLoading == false)
        #expect(vm.canGoNext == false)
        #expect(vm.canGoPrev == false)
    }

    @Test
    func loads_first_page_for_country() async {
        let am = Country.make(code: "AM", name: "Armenia")
        let fake = FakeCityService(
            citiesByCountry: [
                "AM": [
                    .make(name: "Yerevan", countryCode: "AM"),
                    .make(name: "Gyumri",  countryCode: "AM"),
                    .make(name: "Vanadzor", countryCode: "AM"),
                    .make(name: "Hrazdan",  countryCode: "AM")
                ],
                "FR": [
                    .make(name: "Paris", countryCode: "FR")
                ]
            ]
        )
        let vm = CityListViewModel(country: am, service: fake, pageSize: 2)

        vm.loadCities()
        try? await Task.sleep(nanoseconds: 900_000_000)

        #expect(vm.isLoading == false)
        #expect(vm.totalCount == 4)
        #expect(vm.cities.map(\.name) == ["Yerevan", "Gyumri"])
        #expect(vm.canGoPrev == false)
        #expect(vm.canGoNext == true)
    }

    @Test
    func next_then_prev_switches_pages() async {
        let am = Country.make(code: "AM", name: "Armenia")
        let fake = FakeCityService(
            citiesByCountry: [
                "AM": [
                    .make(name: "Yerevan",  countryCode: "AM"),
                    .make(name: "Gyumri",   countryCode: "AM"),
                    .make(name: "Vanadzor", countryCode: "AM"),
                    .make(name: "Hrazdan",  countryCode: "AM")
                ]
            ]
        )
        let vm = CityListViewModel(country: am, service: fake, pageSize: 2)

        vm.loadCities()
        try? await Task.sleep(nanoseconds: 900_000_000)

        vm.nextPage()
        vm.loadCities()
        try? await Task.sleep(nanoseconds: 900_000_000)
        #expect(vm.page == 1)
        #expect(vm.cities.map(\.name) == ["Vanadzor", "Hrazdan"])

        vm.prevPage()
        vm.loadCities()
        try? await Task.sleep(nanoseconds: 900_000_000)
        #expect(vm.page == 0)
        #expect(vm.cities.map(\.name) == ["Yerevan", "Gyumri"])
    }

    @Test
    func last_page_disables_next() async {
        let am = Country.make(code: "AM", name: "Armenia")
        let fake = FakeCityService(
            citiesByCountry: [
                "AM": [
                    .make(name: "Yerevan",  countryCode: "AM"),
                    .make(name: "Gyumri",   countryCode: "AM"),
                    .make(name: "Vanadzor", countryCode: "AM")
                ]
            ]
        )
        let vm = CityListViewModel(country: am, service: fake, pageSize: 2)

        vm.loadCities()
        try? await Task.sleep(nanoseconds: 900_000_000)
        vm.nextPage(); vm.loadCities()
        try? await Task.sleep(nanoseconds: 900_000_000)

        #expect(vm.page == 1)
        #expect(vm.cities.map(\.name) == ["Vanadzor"])
        #expect(vm.canGoNext == false)
        #expect(vm.canGoPrev == true)
    }

    @Test
    func error_clears_data_and_sets_message() async {
        let am = Country.make(code: "AM", name: "Armenia")
        let fake = FakeCityService(citiesByCountry: [:], throwCitiesError: true)
        let vm = CityListViewModel(country: am, service: fake, pageSize: 3)

        vm.loadCities()
        try? await Task.sleep(nanoseconds: 900_000_000)

        #expect(vm.cities.isEmpty)
        #expect(vm.totalCount == 0)
        #expect(vm.message.localizedCaseInsensitiveContains("error") || vm.message.localizedCaseInsensitiveContains("request"))
    }
    
    @Test
    func prev_from_first_does_nothing() async {
        let am = Country.make(code: "AM", name: "Armenia")
        let fake = FakeCityService(citiesByCountry: ["AM": [
            .make(name: "Yerevan", countryCode: "AM"),
            .make(name: "Gyumri", countryCode: "AM")
        ]])
        let vm = CityListViewModel(country: am, service: fake, pageSize: 2)

        vm.loadCities(); try? await Task.sleep(nanoseconds: 900_000_000)
        #expect(vm.page == 0)
        vm.prevPage()
        #expect(vm.page == 0)
    }
    
    @Test
    func empty_result_shows_no_next_and_message() async {
        let am = Country.make(code: "AM", name: "Armenia")
        let fake = FakeCityService(citiesByCountry: ["AM": []])
        let vm = CityListViewModel(country: am, service: fake, pageSize: 3)

        vm.loadCities(); try? await Task.sleep(nanoseconds: 900_000_000)

        #expect(vm.cities.isEmpty)
        #expect(vm.totalCount == 0)
        #expect(vm.canGoNext == false)
        #expect(vm.canGoPrev == false)
        #expect(!vm.message.isEmpty)
    }
    
    @Test
    func short_last_page_disables_next() async {
        let am = Country.make(code: "AM", name: "Armenia")
        let fake = FakeCityService(citiesByCountry: ["AM": [
            .make(name: "A", countryCode: "AM"),
            .make(name: "B", countryCode: "AM"),
            .make(name: "C", countryCode: "AM")
        ]])
        let vm = CityListViewModel(country: am, service: fake, pageSize: 2)

        vm.loadCities(); try? await Task.sleep(nanoseconds: 900_000_000)
        vm.nextPage(); vm.loadCities(); try? await Task.sleep(nanoseconds: 900_000_000)

        #expect(vm.cities.map(\.name) == ["C"])
        #expect(vm.canGoNext == false)
        #expect(vm.canGoPrev == true)
    }
}
