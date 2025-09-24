//
//  MapValidationTests.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 24.09.25.
//

import Testing
@testable import GeoDBExplorer
import CoreLocation

@MainActor
struct MapValidationTests {
    @Test func accepts_valid_coords() {
        let view = CityRowView(city: .make(name: "Yerevan", countryCode: "AM", lat: 40.18, lon: 44.51))
        #expect(view.isValidCoordinate(lat: 40.18, lon: 44.51))
    }

    @Test func rejects_bad_lat() {
        let view = CityRowView(city: .make(name: "X", countryCode: "AM", lat: 123, lon: 44.5))
        #expect(!view.isValidCoordinate(lat: 123, lon: 44.5))
    }

    @Test func rejects_bad_lon() {
        let view = CityRowView(city: .make(name: "X", countryCode: "AM", lat: 40, lon: 200))
        #expect(!view.isValidCoordinate(lat: 40, lon: 200))
    }

    @Test func rejects_nan_inf() {
        let view = CityRowView(city: .make(name: "X", countryCode: "AM"))
        #expect(!view.isValidCoordinate(lat: .infinity, lon: 0))
        #expect(!view.isValidCoordinate(lat: .nan, lon: 0))
    }
}
