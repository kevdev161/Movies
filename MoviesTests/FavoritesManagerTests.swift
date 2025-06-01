//
//  FavoritesManagerTests.swift
//  MoviesTests
//
//  Created by Kevin M Jeggy on 01/06/25.
//

@testable import Movies
import XCTest

class FavoritesManagerTests: XCTestCase {
    var favoritesManager: FavoritesManager!
    let testMovie1 = MovieSearchResult(title: "Favorite Movie 1", year: "2024", imdbID: "fav123", type: "movie", poster: "fav_poster1.jpg")
    let testMovie2 = MovieSearchResult(title: "Favorite Movie 2", year: "2023", imdbID: "fav456", type: "movie", poster: "fav_poster2.jpg")
    private let testFavoritesKey = "favoriteMovies_test" // Use a different key for testing

    override func setUpWithError() throws {
        try super.setUpWithError()
        UserDefaults.standard.removePersistentDomain(forName: #file)
        favoritesManager = FavoritesManager()
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "favoriteMovies")
        favoritesManager = nil
        try super.tearDownWithError()
    }

    func testAddFavorite() {
        XCTAssertFalse(favoritesManager.isFavorite(testMovie1), "Movie should not be a favorite initially.")
        XCTAssertTrue(favoritesManager.favorites.isEmpty, "Favorites list should be empty initially.")

        favoritesManager.toggleFavorite(testMovie1)

        XCTAssertTrue(favoritesManager.isFavorite(testMovie1), "Movie should be a favorite after adding.")
        XCTAssertEqual(favoritesManager.favorites.count, 1, "Favorites list should have one movie.")
        XCTAssertTrue(favoritesManager.favorites.contains(testMovie1), "Favorites set should contain the movie.")
    }

    func testRemoveFavorite() {
        // Add first
        favoritesManager.toggleFavorite(testMovie1)
        XCTAssertTrue(favoritesManager.isFavorite(testMovie1))
        XCTAssertEqual(favoritesManager.favorites.count, 1)

        // Remove
        favoritesManager.toggleFavorite(testMovie1)
        XCTAssertFalse(favoritesManager.isFavorite(testMovie1), "Movie should not be a favorite after removing.")
        XCTAssertTrue(favoritesManager.favorites.isEmpty, "Favorites list should be empty after removing.")
    }

    func testIsFavorite() {
        XCTAssertFalse(favoritesManager.isFavorite(testMovie1))
        favoritesManager.toggleFavorite(testMovie1)
        XCTAssertTrue(favoritesManager.isFavorite(testMovie1))
    }

    func testToggleFavorite_MultipleMovies() {
        favoritesManager.toggleFavorite(testMovie1)
        favoritesManager.toggleFavorite(testMovie2)

        XCTAssertTrue(favoritesManager.isFavorite(testMovie1))
        XCTAssertTrue(favoritesManager.isFavorite(testMovie2))
        XCTAssertEqual(favoritesManager.favorites.count, 2)

        favoritesManager.toggleFavorite(testMovie1) // Remove movie1
        XCTAssertFalse(favoritesManager.isFavorite(testMovie1))
        XCTAssertTrue(favoritesManager.isFavorite(testMovie2))
        XCTAssertEqual(favoritesManager.favorites.count, 1)
    }

    func testLoadFavorites_Persistence() {
        favoritesManager.toggleFavorite(testMovie1)
        XCTAssertTrue(favoritesManager.isFavorite(testMovie1))

        let newFavoritesManager = FavoritesManager()

        XCTAssertTrue(newFavoritesManager.isFavorite(testMovie1), "Favorite should be loaded from UserDefaults.")
        XCTAssertEqual(newFavoritesManager.favorites.count, 1)
        XCTAssertTrue(newFavoritesManager.favorites.contains(where: { $0.imdbID == testMovie1.imdbID }))
    }

    func testLoadFavorites_EmptyState() {
        UserDefaults.standard.removeObject(forKey: "favoriteMovies")
        let newFavoritesManager = FavoritesManager()
        XCTAssertTrue(newFavoritesManager.favorites.isEmpty, "Favorites should be empty if nothing was saved.")
    }

    func testLoadFavorites_CorruptedData() {
        UserDefaults.standard.set("this is not valid data".data(using: .utf8), forKey: "favoriteMovies")

        let newFavoritesManager = FavoritesManager()

        XCTAssertTrue(newFavoritesManager.favorites.isEmpty, "Favorites should be empty after failing to decode corrupted data.")
    }
}
