//
//  Utils.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 26.09.25.
//

import Testing
import Foundation
@testable import GeoDBExplorer

@MainActor
func waitUntil(
  timeoutMs: UInt64 = 500,
  pollMs: UInt64 = 10,
  _ predicate: @MainActor @escaping @Sendable () -> Bool
) async {
    let tries = timeoutMs / pollMs
    for _ in 0..<tries {
        if predicate() { return }
        try? await Task.sleep(nanoseconds: pollMs * 1_000_000)
        await Task.yield()
    }
    #expect(predicate(), "Timed out waiting for condition.")
}

func makeIsolatedDefaults(prefix: String = "tests.suite") -> (suiteName: String, ud: UserDefaults) {
    let suite = "\(prefix).\(UUID().uuidString)"
    guard let ud = UserDefaults(suiteName: suite) else {
        fatalError("Failed to create suite \(suite)")
    }
    UserDefaults.standard.removePersistentDomain(forName: suite)
    return (suite, ud)
}

func removeSuite(_ suiteName: String) {
    UserDefaults.standard.removePersistentDomain(forName: suiteName)
}
