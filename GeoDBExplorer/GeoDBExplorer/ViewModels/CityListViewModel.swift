//
//  CountryDetailsViewModel.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 19.09.25.
//

import Foundation

actor RateGate {
    private var nextAllowedAt: UInt64 = 0
    private let intervalNs: UInt64
    init(milliseconds: Int) { self.intervalNs = UInt64(milliseconds) * 1_000_000 }
    func acquire() async {
        let now = DispatchTime.now().uptimeNanoseconds
        if now < nextAllowedAt { try? await Task.sleep(nanoseconds: nextAllowedAt - now) }
        let start = max(now, nextAllowedAt)
        nextAllowedAt = start + intervalNs
    }
}
let sharedRateGate = RateGate(milliseconds: 400)

@MainActor
final class CityListViewModel: ObservableObject {
    let country: Country
    private let service: GeoDBServicing
    private let pageSize: Int

    @Published private(set) var page = 0
    @Published var cities: [City] = []
    @Published var totalCount = 0
    @Published var isLoading = false
    @Published var message = "Requesting…"

    @Published private var isRateLocked = false

    var canGoPrev: Bool {
        let p = requestedPage ?? page
        return p > 0 && !isLoading && !isRateLocked
    }
    var canGoNext: Bool {
        let p = requestedPage ?? page
        return (p + 1) * pageSize < totalCount && !isLoading && !isRateLocked
    }

    private var currentTask: Task<Void, Never>?
    private var loadVersion = 0
    private var requestedPage: Int?

    init(country: Country, service: GeoDBServicing, pageSize: Int = 7) {
        self.country = country
        self.service = service
        self.pageSize = min(pageSize, 100)
    }

    deinit { currentTask?.cancel() }


    func initialLoad() {
        load(for: 0, keepCooldown: false)
    }

    func nextPage() {
        guard canGoNext else { return }
        let target = (requestedPage ?? page) + 1
        load(for: target, keepCooldown: true)
    }

    func prevPage() {
        guard canGoPrev else { return }
        let target = (requestedPage ?? page) - 1
        load(for: target, keepCooldown: true)
    }


    private func load(for targetPage: Int, keepCooldown: Bool) {
        let previous = currentTask
        previous?.cancel()

        loadVersion &+= 1
        let myVersion = loadVersion

        isLoading = true
        if keepCooldown { isRateLocked = true }
        requestedPage = targetPage
        message = "Loading…"

        currentTask = Task { [weak self] in
            await previous?.value
            guard let self else { return }

            defer {
                if self.loadVersion == myVersion {
                    self.isLoading = false
                    if keepCooldown {
                        Task { [weak self] in
                            try? await Task.sleep(nanoseconds: 600_000_000)
                            self?.isRateLocked = false
                        }
                    }
                    self.requestedPage = nil
                }
            }

            do {
                try Task.checkCancellation()

                await sharedRateGate.acquire()

                let resp = try await self.service.cities(
                    countryCode: self.country.code,
                    limit: self.pageSize,
                    offset: targetPage * self.pageSize,
                    language: "en"
                )

                try Task.checkCancellation()
                guard self.loadVersion == myVersion else { return }

                self.page       = targetPage
                self.cities     = resp.data
                self.totalCount = resp.metadata.totalCount
                self.message    = "Loaded \(self.cities.count) of \(self.totalCount)"
            } catch is CancellationError {
            } catch {
                guard self.loadVersion == myVersion else { return }
                self.message = "Couldn’t load cities. Try again."
            }
        }
    }
}
