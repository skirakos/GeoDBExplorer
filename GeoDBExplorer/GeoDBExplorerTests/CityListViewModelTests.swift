//
//  CityListViewModelTests.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 24.09.25.
//

import Testing
@testable import GeoDBExplorer

@MainActor
struct CityListViewModelTests {
    private func makeVM(
        countryCode: String = "AM",
        service: GeoDBServicing,
        pageSize: Int = 10
    ) -> CityListViewModel {
        CityListViewModel(
            country: .make(code: countryCode, name: "Armenia"),
            service: service,
            pageSize: pageSize,
            throttleInterval: 0
        )
    }

    @Test
    func first_load_calls_service_once_and_updates_state() async {
        let mock = MockGeoDBService()
        mock.nextCities = .success(.make(
            data: [City.make(name: "Yerevan"), City.make(name: "Gyumri")],
            total: 2, offset: 0, limit: 10
        ))

        let vm = makeVM(service: mock, pageSize: 10)
        vm.loadCities()

        await waitUntil { mock.citiesCalls.count == 1 && vm.isLoading == false }

        #expect(mock.citiesCalls.first?.countryCode == "AM")
        #expect(mock.citiesCalls.first?.limit == 10)
        #expect(mock.citiesCalls.first?.offset == 0)
        #expect(mock.citiesCalls.first?.language == "en")

        #expect(vm.cities.map(\.name) == ["Yerevan", "Gyumri"])
        #expect(vm.totalCount == 2)
        #expect(vm.message.localizedLowercase.contains("loaded"))
    }

    private enum Crash: Error { case fail }

    @Test
    func load_error_clears_list_and_stops_loading() async {
        let mock = MockGeoDBService()
        mock.nextCities = .failure(Crash.fail)

        let vm = makeVM(service: mock, pageSize: 10)
        vm.loadCities()

        await waitUntil { mock.citiesCalls.count == 1 && vm.isLoading == false }
        #expect(vm.cities.isEmpty)
        #expect(vm.totalCount == 0)
        #expect(vm.message.localizedLowercase.contains("error"))
    }

    @Test
    func multiple_loads_while_loading_trigger_only_one_request() async {
        let mock = MockGeoDBService()
        mock.nextCities = .success(.make(
            data: [City.make(name: "Yerevan")],
            total: 1, offset: 0, limit: 10
        ))

        let vm = makeVM(service: mock, pageSize: 10)
        vm.loadCities()
        vm.loadCities()
        vm.loadCities()

        await waitUntil { mock.citiesCalls.count == 1 && vm.isLoading == false }
        #expect(mock.citiesCalls.count == 1)
    }

    @Test
    func pageSize_is_capped_in_service_call() async {
        let mock = MockGeoDBService()
        mock.nextCities = .success(.make(data: [], total: 0, offset: 0, limit: 100))

        let vm = makeVM(service: mock, pageSize: 500)
        vm.loadCities()

        await waitUntil { mock.citiesCalls.count == 1 && vm.isLoading == false }
        #expect(mock.citiesCalls.first?.limit == 100)
    }
}
