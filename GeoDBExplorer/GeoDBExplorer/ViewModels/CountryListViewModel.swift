//
//  CountriesViewModel.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 19.09.25.
//

import Foundation

final class Debouncer {
    private let interval: TimeInterval
    private var lastFire: Date = .distantPast
    private var workItem: DispatchWorkItem?
    private let queue = DispatchQueue.main

    init(interval: TimeInterval) { self.interval = interval }

    func schedule(_ block: @escaping () -> Void) {
        workItem?.cancel()

        let now = Date()
        let delay = max(0, interval - now.timeIntervalSince(lastFire))

        let item = DispatchWorkItem { [weak self] in
            self?.lastFire = Date()
            block()
        }
        workItem = item
        queue.asyncAfter(deadline: .now() + delay, execute: item)
    }

    func cancel() { workItem?.cancel() }
}

@MainActor
final class CountryListViewModel: ObservableObject {

    private let service: GeoDBServicing
    private let pageSize: Int

    private let debouncer = Debouncer(interval: 2.0)
    private var currentTask: Task<Void, Never>?

    @Published var countries: [Country] = []
    @Published var totalCount: Int = 0
    @Published var page: Int = 0
    @Published var isLoading: Bool = false
    @Published var message: String = "Requesting…"

    init(service: GeoDBServicing, pageSize: Int = 7) {
        self.service = service
        self.pageSize = min(pageSize, 100)
    }

    var canGoPrev: Bool { page > 0 && !isLoading }
    var canGoNext: Bool { (page + 1) * pageSize < totalCount && !isLoading }

    func loadCountries() {
        debouncer.schedule { [weak self] in
            Task { await self?.performLoad() }
        }
    }

    private func performLoad() async {
        currentTask?.cancel()

        currentTask = Task { [weak self] in
            guard let self else { return }
            self.isLoading = true
            self.message   = "Loading…"
            defer { self.isLoading = false }

            let lang = "en"

            do {
                let resp = try await self.service.countries(
                    limit: self.pageSize,
                    offset: self.page * self.pageSize,
                    language: lang
                )

                if Task.isCancelled { return } // ignore stale result

                self.countries  = resp.data
                self.totalCount = resp.metadata.totalCount
                self.message    = "Loaded \(self.countries.count) of \(self.totalCount)"
            } catch {
                if error is CancellationError { return }
                self.countries  = []
                self.totalCount = 0
                self.message    = "Loading..."
            }
        }

        await currentTask?.value
    }

    func nextPage() {
        guard (page + 1) * pageSize < totalCount, !isLoading else { return }
        isLoading = true
        page += 1
        loadCountries()
    }

    func prevPage() {
        guard page > 0, !isLoading else { return }
        isLoading = true
        page -= 1
        loadCountries()
    }
}
