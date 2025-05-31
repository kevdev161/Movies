//
//  MovieListViewModel.swift
//  Movies
//
//  Created by Kevin M Jeggy on 31/05/25.
//

import Combine
import Foundation

class MovieListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var movies: [MovieSearchResult] = []
    @Published var popularMovies: [MovieSearchResult] = []
    @Published var currentPage = 1
    @Published var totalResults = 0
    @Published var isLoading = false
    @Published var hasMorePages = true
    @Published var searchText = "" {
        didSet {
            if searchText.count > 2 {
                resetSearch()
            }
        }
    }

    // MARK: - Private Properties
    private let apiKey = "9893379e"

    // MARK: - Initialization
    init() {
        fetchPopularMovies()
    }

    // MARK: - API Calls

    /// Fetches movies based on the search text and appends them to the `movies` array.
    func fetchMovies() {
        guard !isLoading, hasMorePages, !searchText.isEmpty else { return }
        isLoading = true

        let urlString = "https://www.omdbapi.com/?apikey=\(apiKey)&s=\(searchText)&page=\(currentPage)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let data = data {
                do {
                    let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.movies.append(contentsOf: response.search)
                        self?.totalResults = Int(response.totalResults) ?? 0

                        let totalPages = Int(ceil(Double(self?.totalResults ?? 0) / 10.0))
                        if let currentPage = self?.currentPage, currentPage >= totalPages {
                            self?.hasMorePages = false
                        } else {
                            self?.currentPage += 1
                        }
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    /// Fetches popular movies (placeholder, as OMDB doesn’t officially support popularity).
    func fetchPopularMovies() {
        guard !isLoading, hasMorePages, !searchText.isEmpty else { return }
        isLoading = true

        let urlString = "https://www.omdbapi.com/?apikey=\(apiKey)&s=popular"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let data = data {
                do {
                    let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.popularMovies.append(contentsOf: response.search)
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    // MARK: - Helpers

    /// Resets the search and starts fetching movies from page 1.
    func resetSearch() {
        movies = []
        currentPage = 1
        totalResults = 0
        hasMorePages = true
        fetchMovies()
    }
}
