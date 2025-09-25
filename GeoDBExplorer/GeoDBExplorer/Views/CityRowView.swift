//
//  CityRowView.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 20.09.25.
//

import SwiftUI
import Foundation
import MapKit

struct CityRowView: View {
    let city: City
    let isValidCoordinate: Bool
    
    private var coord: CLLocationCoordinate2D {
        .init(latitude: city.latitude, longitude: city.longitude)
    }
    private var region: MKCoordinateRegion {
        .init(
            center: coord,
            span: .init(latitudeDelta: 1, longitudeDelta: 1)
        )
    }
    var body: some View {
        if isValidCoordinate {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.name).font(.body)
                HStack(spacing: 8) {
                    if let r = city.region, !r.isEmpty { Text(r) }
                    if let p = city.population { Text("• \(p)") }
                }
                .font(.caption).foregroundStyle(.secondary)
                
                Map(initialPosition: .region(region)) {
                    Marker(city.name, coordinate: coord)
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .allowsHitTesting(false)

            }
            .padding(8)
        } else {
            ContentUnavailableView("Invalid location",
                                   systemImage: "mappin.slash",
                                   description: Text("This item has bad coordinates."))
                .frame(height: 180)
        }
    }
}
