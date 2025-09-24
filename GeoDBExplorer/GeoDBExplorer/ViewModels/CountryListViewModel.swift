//
//  CountriesViewModel.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 19.09.25.
//

import Foundation

@MainActor
final class CountryListViewModel: ObservableObject {

    private let service: GeoDBServicing
    private let pageSize: Int

    @Published var countries: [Country] = []
    @Published var totalCount: Int = 0
    @Published var page: Int = 0
    @Published var isLoading: Bool = false
    @Published var message: String = "Requesting…"

    init(service: GeoDBServicing, pageSize: Int = 7) {
        self.service = service
        self.pageSize = pageSize
    }

    var canGoPrev: Bool { page > 0 && !isLoading }
    var canGoNext: Bool { (page + 1) * pageSize < totalCount && !isLoading }
    
    private var currentTask: Task<Void, Never>?
    private var debounceTask: Task<Void, Never>?
    
    func loadCountries() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 800_000_000)
            await self?.performLoadCountries()
        }
    }

    private func performLoadCountries() async {
        currentTask?.cancel()

        let lang = "en"

        currentTask = Task { [weak self] in
            guard let self else { return }
            self.message = "Loading…"
            self.isLoading = true
            defer { self.isLoading = false }

            do {
                let resp = try await self.service.countries(
                    limit: self.pageSize,
                    offset: self.page * self.pageSize,
                    language: lang
                )
                if Task.isCancelled { return }
                self.countries  = resp.data
                self.totalCount = resp.metadata.totalCount
                self.message    = "Loaded \(self.countries.count) of \(self.totalCount)"
            } catch {
                if Task.isCancelled { return }
                self.countries = []
                self.totalCount = 0
                self.message = "Request error: \(error.localizedDescription)"
            }
        }

        await currentTask?.value
    }

    func nextPage() {
        guard (page + 1) * pageSize < totalCount, !isLoading else { return }
        isLoading = true
        page += 1
    }

    func prevPage() {
        guard page > 0, !isLoading else { return }
        isLoading = true
        page -= 1
    }
}
