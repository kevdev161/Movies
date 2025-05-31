//
//  MoviesListScreen.swift
//  Movies
//
//  Created by Kevin M Jeggy on 31/05/25.
//

import SwiftUI

struct MoviesListScreen: View {
    @StateObject private var viewModel = MovieListViewModel()
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Movies")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    NavigationLink {
                        FavoritesScreen()
                            .environmentObject(favoritesManager)
                    } label: {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                }
                TextField("Search movies...", text: $viewModel.searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .disableAutocorrection(true)
                if !viewModel.isLoading, viewModel.movies.isEmpty, !viewModel.searchText.isEmpty {
                    NoMoviesFoundView(searchText: viewModel.searchText) {
                        viewModel.resetSearch()
                    }.frame(maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.movies.indices, id: \.self) { index in
                                let movie = viewModel.movies[index]
                                MovieListCard(movie: movie)
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
                        }.environmentObject(favoritesManager)
                    }
                }
            }.padding(.horizontal, 20)
                .padding(.vertical, 32)
                .scrollDismissesKeyboard(.immediately)
                .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}
