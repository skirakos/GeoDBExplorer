//
//  FavoritesView.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 20.09.25.
//
import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favCountriesVM: FavoriteCountriesViewModel
    @ObservedObject var favCitiesVM:    FavoriteCitiesViewModel

    var body: some View {
        List {
            Section("Countries") {
                ForEach(favCountriesVM.items, id: \.self) { c in
                    Text(c.name)
                }
                .onDelete { indexSet in
                    for i in indexSet {
                        _ = favCountriesVM.remove(code: favCountriesVM.items[i].code)
                    }
                }
            }
            Section("Cities") {
                ForEach(favCitiesVM.items, id: \.self) { city in
                    Text(city.name)
                }
                .onDelete { indexSet in
                    for i in indexSet {
                        _ = favCitiesVM.remove(code: favCitiesVM.items[i].id)
                    }
                }
            }
        }
        .navigationTitle("Favorites")
    }
}
