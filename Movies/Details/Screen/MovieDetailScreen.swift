//
//  MovieDetailScreen.swift
//  Movies
//
//  Created by Kevin M Jeggy on 31/05/25.
//

import SwiftUI

extension MovieDetailScreen {
    init(_ movie: MovieSearchResult) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie))
    }
}

struct MovieDetailScreen: View {
    @StateObject var viewModel: MovieDetailViewModel
    @EnvironmentObject var favoritesManager: FavoritesManager
    var body: some View {
        VStack(spacing: 0) {
            if let movie = viewModel.movie {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        AsyncImage(url: URL(string: movie.poster)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 160, height: 240)
                                    .clipped()
                            } else if phase.error != nil {
                                Image("PosterPlaceholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 160, height: 240)
                                    .clipped()
                            } else {
                                ProgressView()
                                    .frame(width: 160, height: 240)
                            }
                        }.frame(width: 160, height: 240)
                            .clipped()
                        Button {
                            withAnimation {
                                favoritesManager.toggleFavorite(viewModel.result)
                            }
                        } label: {
                            HStack(spacing: 16) {
                                if favoritesManager.isFavorite(viewModel.result) {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(.red)
                                    Text("Remove from favorites")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.textPrimary)
                                } else {
                                    Image(systemName: "heart")
                                        .foregroundStyle(.iconPrimary)
                                    Text("Add to favorites")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.textPrimary)
                                }

                            }.padding()
                                .frame(maxWidth: .infinity)
                                .background(.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }.overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.gray, lineWidth: 0.5)
                        }
                        VStack(alignment: .leading, spacing: 16) {
                            Text(movie.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.textPrimary)
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                        Text(movie.imdbRating)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.textPrimary)
                                    }
                                    HStack(spacing: 2) {
                                        Image(systemName: "calendar")
                                            .foregroundStyle(.iconSecondary)
                                        Text(movie.year)
                                            .font(.subheadline)
                                            .foregroundStyle(.textSecondary)
                                    }
                                    HStack(spacing: 2) {
                                        Image(systemName: "timer")
                                            .foregroundStyle(.iconSecondary)
                                        Text(movie.runtime)
                                            .font(.subheadline)
                                            .foregroundStyle(.textSecondary)
                                    }
                                }
                                HStack(spacing: 8) {
                                    HStack(spacing: 2) {
                                        Image(systemName: "film")
                                            .foregroundStyle(.iconSecondary)
                                        Text(movie.genre)
                                            .font(.subheadline)
                                            .foregroundStyle(.textSecondary)
                                    }
                                    HStack(spacing: 2) {
                                        Image(systemName: "movieclapper")
                                            .foregroundStyle(.iconSecondary)
                                        Text(movie.type)
                                            .font(.subheadline)
                                            .foregroundStyle(.textSecondary)
                                    }
                                }
                            }
                            VStack(alignment: .leading, spacing: 16) {
                                DetailWrapperView(title: "Plot", description: movie.plot)
                                DetailWrapperView(title: "Language", description: movie.language)
                                DetailWrapperView(title: "Director", description: movie.director)
                                DetailWrapperView(title: "Writer", description: movie.writer)
                                DetailWrapperView(title: "Actors", description: movie.actors)
                                DetailWrapperView(title: "Awards", description: movie.awards)
                                DetailWrapperView(title: "Country", description: movie.country)
                                DetailWrapperView(title: "Language", description: movie.language)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

            } else if viewModel.isLoading {
                ProgressView()
            } else {
                NoMoviesFoundView(errorTitle: "Something went wrong.") {
                    viewModel.fetchDetails()
                }
            }
        }.padding(.horizontal, 20)
    }
}

private struct DetailWrapperView: View {
    let title: String
    let description: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.textPrimary)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.leading)
        }.padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.gray, lineWidth: 0.5)
            }
    }
}
