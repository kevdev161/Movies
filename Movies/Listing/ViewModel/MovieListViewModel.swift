//
//  MovieListViewModel.swift
//  Movies
//
//  Created by Kevin M Jeggy on 31/05/25.
//

import Foundation
import Combine

class MovieListViewModel: ObservableObject {
    @Published var movies: [MovieSearchResult] = []
    @Published var currentPage = 1
    @Published var totalResults = 0
    @Published var isLoading = false
    @Published var hasMorePages = true
    @Published var searchText = "" 

    private let apiKey = "9893379e"

    func fetchMovies() {
        guard !isLoading, hasMorePages, !searchText.isEmpty else { return }
        isLoading = true

        let urlString = "https://www.omdbapi.com/?apikey=\(apiKey)&s=\(searchText)&page=\(currentPage)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
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

    func resetSearch() {
        movies = []
        currentPage = 1
        totalResults = 0
        hasMorePages = true
        fetchMovies()
    }
}
