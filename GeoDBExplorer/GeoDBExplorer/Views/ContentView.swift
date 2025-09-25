//
//  ContentView.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 03.09.25.
//

import SwiftUI
import MapKit
import Foundation


enum AppTab: Hashable { case countries, favorites, profile }

struct ContentView: View {
    private let service: GeoDBServicing

    init() {
        let network = NetworkManager(
            baseURL: URL(string: "https://wft-geo-db.p.rapidapi.com")!,
            apiKey: "f5f94d4850msh98f4b69b5c51ee0p1ee57ejsn78cb557e5f6a",
            hostHeader: "wft-geo-db.p.rapidapi.com",
            retry: .oneRetry
        )
        self.service = GeoDBService(network: network)
    }
    @StateObject private var favCountriesVM = FavoriteCountriesViewModel(store: FavoriteCountriesStore())
    @StateObject private var favCitiesVM    = FavoriteCitiesViewModel(store: FavoriteCitiesStore())

    var body: some View {
        TabView {
            NavigationStack {
                CountriesView(service: service,
                              favCountriesVM: favCountriesVM,
                              favCitiesVM: favCitiesVM)
            }
            .tabItem { Label("Countries", systemImage: "globe.europe.africa.fill") }

            NavigationStack {
                FavoritesView(favCountriesVM: favCountriesVM,
                              favCitiesVM: favCitiesVM)
            }
            .tabItem { Label("Favorites", systemImage: "heart.fill") }

            NavigationStack { ProfileView() }
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
    }
}

//#Preview {
//    ContentView()
//}
