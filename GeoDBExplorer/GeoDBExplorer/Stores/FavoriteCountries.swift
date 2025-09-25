////
////  FavoriteCountries.swift
////  GeoDBExplorer
////
////  Created by Seda Kirakosyan on 20.09.25.
////
//
//import SwiftUI
//
//@MainActor
//final class FavoriteCountries: ObservableObject {
//    @Published var favCountries: [FavoriteCountry] = [] {
//        didSet { keep() }
//    }
//    
//    init() {
//        if let data = UserDefaults.standard.data(forKey: "fav"),
//           let items = try? JSONDecoder().decode([FavoriteCountry].self, from: data) {
//            self.favCountries = items
//        }
//    }
//
//    func isFavorite(_ code: String) -> Bool {
//        favCountries.contains { $0.code == code }
//    }
//    
//    func add(_ country: Country) {
//        guard !isFavorite(country.code) else { return }
//        favCountries.append(.init(code: country.code, name: country.name))
//    }
//    
//    func remove(_ code: String) -> Bool {
//        if let i = favCountries.firstIndex(where: { $0.code == code }) {
//            favCountries.remove(at: i)
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func toggle(_ country: Country) {
//        isFavorite(country.code) ? _ = remove(country.code) : add(country)
//    }
//    
//    private func keep() {
//        if let data = try? JSONEncoder().encode(favCountries) {
//            UserDefaults.standard.set(data, forKey: "fav")
//        }
//    }
//}
