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
    private let service = GeoDBServiceLive(apiKey: "f5f94d4850msh98f4b69b5c51ee0p1ee57ejsn78cb557e5f6a")

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



//https://wft-geo-db.p.rapidapi.com/v1/geo/places/Q65/distance?toPlaceId=Q60
//#Preview {
//    ContentView()
//}
