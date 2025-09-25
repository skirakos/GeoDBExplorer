//
//  CountryDetailsViewModel.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 19.09.25.
//

import Foundation

// CityListViewModel.swift
import Foundation

@MainActor
final class CityListViewModel: ObservableObject {
    let country: Country
    private let service: GeoDBServicing
    private let pageSize: Int

    // throttle + cancel just like CountryListViewModel
    private let throttler = Throttler(interval: 2.0)
    private var currentTask: Task<Void, Never>?

    @Published private(set) var page = 0
    @Published var cities: [City] = []
    @Published var totalCount = 0
    @Published var isLoading = false
    @Published var message = "Requesting…"

    // keep this in the VM per your feedback
    func isValidCoordinate(lat: Double?, lon: Double?) -> Bool {
        guard let lat = lat, let lon = lon,
              lat.isFinite, lon.isFinite,
              (-90.0...90.0).contains(lat),
              (-180.0...180.0).contains(lon)
        else { return false }
        return true
    }

    init(country: Country, service: GeoDBServicing, pageSize: Int = 7) {
        self.country = country
        self.service = service
        self.pageSize = min(pageSize, 100)
    }

    deinit { currentTask?.cancel() }

    var canGoPrev: Bool { page > 0 && !isLoading }
    var canGoNext: Bool { (page + 1) * pageSize < totalCount && !isLoading }

    // PUBLIC entry — schedule a throttled load of the current page
    func loadCities() {
        throttler.schedule { [weak self] in
            Task { await self?.performLoad() }
        }
    }

    // call this on first appear
    func initialLoad() { loadCities() }

    func nextPage() {
        guard canGoNext else { return }
        isLoading = true        // lock quickly in UI
        page += 1
        loadCities()
    }

    func prevPage() {
        guard canGoPrev else { return }
        isLoading = true
        page -= 1
        loadCities()
    }

    private func langCode() -> String {
        UserDefaults.standard.string(forKey: "app.language") ?? "en"
    }

    private func performLoad() async {
        // cancel any in-flight request
        currentTask?.cancel()

        currentTask = Task { [weak self] in
            guard let self else { return }
            self.isLoading = true
            self.message   = "Loading…"
            defer { self.isLoading = false }

            do {
                let resp = try await self.service.cities(
                    countryCode: self.country.code,
                    limit: self.pageSize,
                    offset: self.page * self.pageSize,
                    language: self.langCode()
                )

                if Task.isCancelled { return } // ignore stale result

                self.cities     = resp.data
                self.totalCount = resp.metadata.totalCount
                self.message    = "Loaded \(self.cities.count) of \(self.totalCount)"
            } catch {
                if error is CancellationError { return } // silence cancel
                self.cities     = []
                self.totalCount = 0
                self.message    = "Request error: \(error.localizedDescription)"
            }
        }

        await currentTask?.value
    }
}
