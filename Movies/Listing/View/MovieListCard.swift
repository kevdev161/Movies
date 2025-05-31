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
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                Text(movie.year)
                    .font(.subheadline)
                HStack(spacing: 4) {
                    Image(systemName: "movieclapper")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.black)
                    Text(movie.type.capitalized)
                        .font(.footnote)
                }.padding(.vertical, 8)
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
        }.frame(minHeight: 120)

            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.gray, lineWidth: 0.5)
            }
            .padding(.horizontal, 20)
    }
}
