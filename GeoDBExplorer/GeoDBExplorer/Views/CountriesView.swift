//
//  CountriesView.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 20.09.25.
//

import SwiftUI

struct CountriesView: View {
    let service: GeoDBServicing
    @EnvironmentObject var favs: FavoriteCountries

    @StateObject private var vm: CountryListViewModel

    init(service: GeoDBServicing) {
        self.service = service
        _vm = StateObject(wrappedValue: CountryListViewModel(service: service, pageSize: 7))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.countries.isEmpty && vm.isLoading {
                    ProgressView("Loading countries…").padding()
                } else if vm.countries.isEmpty {
                    ScrollView { Text(vm.message).monospaced().textSelection(.enabled).padding() }
                } else {
                    List(vm.countries) { c in
                        NavigationLink {
                            CountryDetailsView(country: c, service: service)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(c.name).font(.headline)
                                    HStack(spacing: 8) {
                                        Text(c.code)
                                        if let capital = c.capital, !capital.isEmpty { Text("• \(capital)") }
                                        if let region = c.region, !region.isEmpty { Text("• \(region)") }
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 6)

                                Spacer()
                                Button { favs.toggle(c) } label: {
                                    Image(systemName: favs.isFavorite(c.code) ? "heart.fill" : "heart")
                                        .imageScale(.large)
                                        .foregroundStyle(.blue)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .overlay(alignment: .top) {
                        if vm.isLoading { ProgressView().padding(.top, 8) }
                    }
                }
            }
            .navigationTitle("Countries")
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
        .task(id: vm.page) {
            vm.loadCountries()
            try? await Task.sleep(nanoseconds: 1_100_000_000)
        }
    }
}

