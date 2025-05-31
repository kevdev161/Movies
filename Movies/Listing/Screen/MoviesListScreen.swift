//
//  MoviesListScreen.swift
//  Movies
//
//  Created by Kevin M Jeggy on 31/05/25.
//

import SwiftUI

struct MoviesListView: View {
    @StateObject private var viewModel = MovieListViewModel()
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("Search movies...", text: $viewModel.searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .disableAutocorrection(true)
                Button {
                    viewModel.resetSearch()
                } label: {
                    Text("Done")
                }

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.movies.indices, id: \.self) { index in
                            let movie = viewModel.movies[index]
                            MovieListCard(movie: movie)
                            Button(action: {
                                favoritesManager.toggleFavorite(movie)
                            }) {
                                Image(systemName: favoritesManager.isFavorite(movie) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                            .onAppear {
                                if index == viewModel.movies.count - 1 {
                                    viewModel.fetchMovies()
                                }
                            }
                        }
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("Movies")
        }.background(Color.white)
    }
}
