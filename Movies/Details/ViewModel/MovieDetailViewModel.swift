//
//  MovieDetailViewModel.swift
//  Movies
//
//  Created by Kevin M Jeggy on 01/06/25.
//

import Foundation

class MovieDetailViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var result: MovieSearchResult
    @Published var movie: MoviesModel?

    // MARK: - Private Properties
    private let apiKey = "9893379e"
    private var urlSession: URLSessionProtocol

    init(_ movie: MovieSearchResult, urlSession: any URLSessionProtocol = URLSession.shared) {
        self.result = movie
        self.urlSession = urlSession
        fetchDetails()
    }

    func fetchDetails() {
        isLoading = true

        let urlString = "https://omdbapi.com/?apikey=\(apiKey)&i=\(result.imdbID)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            isLoading = false
            return
        }

        self.urlSession.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let data = data {
                do {
                    let response = try JSONDecoder().decode(MoviesModel.self, from: data)
                    DispatchQueue.main.async {
                        self?.movie = response
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}
