//
//  FavoritesManager.swift
//  Movies
//
//  Created by Kevin M Jeggy on 31/05/25.
//

import Foundation

class FavoritesManager: ObservableObject {
    @Published private(set) var favorites: Set<MovieSearchResult> = []

    private let favoritesKey = "favoriteMovies"

    init() {
        loadFavorites()
    }

    func isFavorite(_ movie: MovieSearchResult) -> Bool {
        favorites.contains(where: { $0.imdbID == movie.imdbID })
    }

    func toggleFavorite(_ movie: MovieSearchResult) {
        if let existing = favorites.first(where: { $0.imdbID == movie.imdbID }) {
            favorites.remove(existing)
        } else {
            favorites.insert(movie)
        }
        saveFavorites()
    }

    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else {
            favorites = []
            return
        }

        do {
            let decoded = try JSONDecoder().decode(Set<MovieSearchResult>.self, from: data)
            favorites = decoded
        } catch {
            print("Failed to decode favorites: \(error)")
            favorites = []
        }
    }

    private func saveFavorites() {
        do {
            let encoded = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        } catch {
            print("Failed to save favorites: \(error)")
        }
    }
}
