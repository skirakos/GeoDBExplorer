//
//  CountryListViewModelTests.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 23.09.25.
//

import Testing
@testable import GeoDBExplorer

@MainActor
struct CountryListViewModelTests {
    private func makeVM(service: GeoDBServicing, pageSize: Int = 10) -> CountryListViewModel {
        CountryListViewModel(
            service: service,
            pageSize: pageSize
        )
    }

    @Test
    func first_load_calls_service_once_and_updates_state() async {
        let mock = MockGeoDBService()
        let list = [Country.make(code: "AM", name: "Armenia"),
                    Country.make(code: "FR", name: "France")]
        mock.nextCountries = .success(.make(data: list, total: 2, offset: 0, limit: 10))

        let vm = makeVM(service: mock, pageSize: 10)

        vm.loadCountries()

        await waitUntil {
            mock.countriesCalls.count == 1 && vm.isLoading == false
        }

        #expect(mock.countriesCalls.first?.limit == 10)
        #expect(mock.countriesCalls.first?.offset == 0)
        #expect(mock.countriesCalls.first?.language == "en")

        #expect(vm.countries.map(\.code) == ["AM", "FR"])
        #expect(vm.totalCount == 2)
        #expect(vm.message.contains("Loaded"))
    }
    
    private enum Crash: Error { case fail }

    @Test
    func load_error_clears_list_and_stops_loading() async {
        let mock = MockGeoDBService()
        mock.nextCountries = .failure(Crash.fail)

        let vm = makeVM(service: mock, pageSize: 10)

        vm.loadCountries()
        await waitUntil { mock.countriesCalls.count == 1 && vm.isLoading == false }

        #expect(vm.countries.isEmpty)
        #expect(vm.totalCount == 0)
    }
    
    @Test
    func multiple_loads_while_loading_trigger_only_one_request() async {
        let mock = MockGeoDBService()
        mock.nextCountries = .success(.make(
            data: [Country.make()],
            total: 1,
            offset: 0,
            limit: 10
        ))

        let vm = makeVM(service: mock, pageSize: 10)

        vm.loadCountries()
        vm.loadCountries()
        vm.loadCountries()

        await waitUntil { mock.countriesCalls.count == 1 && vm.isLoading == false }
        #expect(mock.countriesCalls.count == 1)
    }
    
    @Test
    func pageSize_is_capped_in_service_call() async {
        let mock = MockGeoDBService()
        mock.nextCountries = .success(.make(data: [], total: 0, offset: 0, limit: 100))

        let vm = makeVM(service: mock, pageSize: 500)
        vm.loadCountries()

        await waitUntil { mock.countriesCalls.count == 1 && vm.isLoading == false }
        #expect(mock.countriesCalls.first?.limit == 100)
    }
}

