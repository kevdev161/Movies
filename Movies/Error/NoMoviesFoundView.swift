//
//  NoMoviesFoundView.swift
//  Movies
//
//  Created by Kevin M Jeggy on 31/05/25.
//

import SwiftUI

struct NoMoviesFoundView: View {
    let errorTitle: String
    let errorDescription: String
    var onRetry: (() -> Void)?

    init(searchText: String? = nil, errorTitle: String? = nil, errorDescription: String? = nil, onRetry: (() -> Void)? = nil) {
        self.errorTitle = errorTitle ?? (searchText?.count ?? 0 > 2 ? "No Movies Found" : "Too many results")
        self.errorDescription = errorDescription ?? (searchText?.count ?? 0 > 2 ? "Try a different search or check your spelling." : "Try being more specific in your search.")
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)

            Text(errorTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black)

            Text(errorDescription)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text("Try Again")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)
            }
        }
        .padding()
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(20)
    }
}
