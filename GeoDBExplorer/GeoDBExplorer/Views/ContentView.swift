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
    
    @StateObject private var favs = FavoriteCountries()
    @StateObject private var favCities = FavoriteCities()

    
    var body: some View {
        TabView() {
            NavigationStack {
                VStack {
                    CountriesView(service: service)
                }
            }
            .tabItem { Label("Countries", systemImage: "globe.europe.africa.fill") }
            .tag(AppTab.countries)
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem { Label("Favorites", systemImage: "heart.fill") }
            .tag(AppTab.favorites)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
            .tag(AppTab.profile)
        }
        .environmentObject(favs)
        .environmentObject(favCities)
    }
}



//https://wft-geo-db.p.rapidapi.com/v1/geo/places/Q65/distance?toPlaceId=Q60
#Preview {
    ContentView()
}
