//
//  FavoritesView.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 20.09.25.
//
import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favCountries: FavoriteCountries
    @EnvironmentObject var favCities: FavoriteCities
    
    var body: some View {
        VStack {
            Text("Favorite countries")
                .font(.headline)
            
            List {
                Section("Countries") {
                    ForEach(favCountries.favCountries, id: \.self) { city in
                        Text(city.name)
                    }
                    .onDelete { indexSet in
                        for i in indexSet {
                            _ = favCountries.remove(favCountries.favCountries[i].code)
                        }
                    }
                }
                
                Section("Cities") {
                    ForEach(favCities.favCities, id: \.self) { city in
                        Text(city.name)
                    }
                    .onDelete { indexSet in
                        for i in indexSet {
                            _ = favCities.remove(favCities.favCities[i].id)
                        }
                    }
                }
            }
           
        }
    }
}
