//
//  FavoritesScreen.swift
//  Movies
//
//  Created by Kevin M Jeggy on 01/06/25.
//

import SwiftUI

struct FavoritesScreen: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                if favoritesManager.favorites.isEmpty {
                    NoMoviesFoundView(errorTitle: "No favorites.", errorDescription: "Your favorites will be listed here.")
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(Array(favoritesManager.favorites), id: \.self) { favorite in
                                    MovieListCard(movie: favorite)
                                }
                            }
                        }.padding(.vertical, 20)
                    }
                }
            }.padding(.horizontal, 20)
                .background(Color.backgroundPrimary)
                .navigationTitle("Favorites")
                .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

#Preview {
    FavoritesScreen()
}
