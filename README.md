# GeoDBExplorer

GeoDBExplorer is an iOS app built with **SwiftUI** that lets you explore countries and their cities using the [GeoDB Cities API](https://rapidapi.com/wirefreethought/api/geodb-cities/).  
It supports browsing, pagination, favorites, and basic profile management.

---

## Features

- **Browse Countries**  
  - Paginated list of countries with code, capital, and region.  
  - Navigation into details for each country.

- **Explore Cities**  
  - Paginated list of cities for a selected country.  
  - Each city shows its name, region, population, and coordinates on a map.  
  - Built-in coordinate validation to avoid broken map pins.

- **Favorites**  
  - Mark countries and cities as favorites.  
  - Favorites are persisted locally with `UserDefaults`.  
  - Favorites screen lists all saved items, with swipe-to-delete.

- **Profile**  
  - Store your first/last name, short bio, and preferred app language.  
  - Pick and save a profile picture (saved in local storage).  

- **Networking**  
  - Custom `NetworkManager` with retry for API rate-limits (429).  
  - `GeoDBService` wraps the GeoDB API endpoints.  
  - Throttling to avoid excessive API calls.

- **Architecture**  
  - **MVVM** with `CountryListViewModel` and `CityListViewModel`.  
  - `FavoriteCountriesViewModel` and `FavoriteCitiesViewModel` for persistence.  
  - Unit tests with `swift-testing` for view models, favorites, and validation logic.

---

## Getting Started

### Requirements
- Xcode 15+
- iOS 17+
- Swift Concurrency
- RapidAPI key for GeoDB Cities

### Setup
1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd GeoDBExplorer
