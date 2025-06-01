//
//  MovieListCard.swift
//  Movies
//
//  Created by Kevin M Jeggy on 31/05/25.
//

import SwiftUI

struct MovieListCard: View {
    let movie: MovieSearchResult
    @EnvironmentObject var favoritesManager: FavoritesManager
    var body: some View {
        NavigationLink {
            MovieDetailScreen(movie)
                .environmentObject(favoritesManager)
        } label: {
            HStack(alignment: .top, spacing: 0) {
                AsyncImage(url: URL(string: movie.poster)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 120)
                            .clipped()
                    } else if phase.error != nil {
                        Image("PosterPlaceholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 120)
                            .clipped()
                    } else {
                        ProgressView()
                            .frame(width: 80, height: 120)
                    }
                }.frame(width: 80, height: 120)
                    .clipped()
                VStack(alignment: .leading, spacing: 2) {
                    Text(movie.title)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .accessibilityIdentifier("movieTitle_\(movie.imdbID)")
                    Text(movie.year)
                        .font(.subheadline)
                        .foregroundStyle(.textPrimary)
                    HStack(spacing: 4) {
                        Image(systemName: "movieclapper")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.iconPrimary)
                        Text(movie.type.capitalized)
                            .font(.footnote)
                            .foregroundStyle(.textPrimary)
                    }.padding(.vertical, 8)
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }.frame(minHeight: 120)
                .background(.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.gray, lineWidth: 0.5)
                }

                .overlay(alignment: .top) {
                    Button {
                        withAnimation(.easeInOut) {
                            favoritesManager.toggleFavorite(movie)
                        }
                    } label: {
                        if favoritesManager.isFavorite(movie) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                        } else {
                            Image(systemName: "heart")
                                .foregroundStyle(.iconPrimary)
                        }
                    }.accessibilityIdentifier("favoriteButton_\(movie.imdbID)")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(8)
                }
        }
    }
}
