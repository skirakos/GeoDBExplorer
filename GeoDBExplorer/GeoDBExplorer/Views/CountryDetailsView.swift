//
//  CountryDetailsView.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 20.09.25.
//

import SwiftUI

struct CountryDetailsView: View {
    @EnvironmentObject var favCities: FavoriteCities

    @StateObject private var vm: CityListViewModel
    @AppStorage("app.language") private var lang = "en"

    init(country: Country, service: GeoDBServicing) {
        _vm = StateObject(
            wrappedValue: CityListViewModel(country: country, service: service, pageSize: 7)
        )
    }

    var body: some View {
        List {
            LabeledContent("Code", value: vm.country.code)
            if let capital = vm.country.capital, !capital.isEmpty {
                LabeledContent("Capital", value: capital)
            }
            if let region = vm.country.region, !region.isEmpty {
                LabeledContent("Region", value: region)
            }
            if let codes = vm.country.currencyCodes, !codes.isEmpty {
                LabeledContent("Currencies", value: codes.joined(separator: ", "))
            }

            Section("Cities") {
                if vm.isLoading && vm.cities.isEmpty {
                    ProgressView("Loading cities…")
                } else if vm.cities.isEmpty {
                    Text(vm.message).font(.footnote).foregroundStyle(.secondary)
                } else {
                    ForEach(vm.cities) { city in
                        NavigationLink {
                            CityRowView(city: city)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(city.name).font(.body)
                                    HStack(spacing: 8) {
                                        if let r = city.region, !r.isEmpty { Text(r) }
                                        if let p = city.population { Text("• \(p)") }
                                    }
                                    .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button { favCities.toggle(city) } label: {
                                    Image(systemName: favCities.isFavorite(city.id) ? "heart.fill" : "heart")
                                        .imageScale(.large)
                                        .foregroundStyle(.blue)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .onAppear { vm.initialLoad() }
        .navigationTitle(vm.country.name)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Prev") { vm.prevPage() }.disabled(!vm.canGoPrev)
                Spacer()
                Text(vm.isLoading
                     ? "Loading…"
                     : "Page \(vm.page + 1)  • \(vm.totalCount)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Next") { vm.nextPage() }.disabled(!vm.canGoNext)
            }
        }
    }
}
