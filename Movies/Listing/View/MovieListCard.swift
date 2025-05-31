//
//  MovieListCard.swift
//  Movies
//
//  Created by Kevin M Jeggy on 31/05/25.
//

import SwiftUI

struct MovieListCard: View {
    let movie: MovieSearchResult
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            AsyncImage(url: URL(string: movie.poster)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
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
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(movie.title)
                    .font(.headline)
                Text(movie.year)
                    .font(.subheadline)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.padding(16)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.gray, lineWidth: 0.5)
            }
            .padding(.horizontal, 20)
    }
}
