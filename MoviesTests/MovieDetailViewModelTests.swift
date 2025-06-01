//
//  MovieDetailViewModelTests.swift
//  MoviesTests
//
//  Created by Kevin M Jeggy on 01/06/25.
//

import Combine
@testable import Movies
import XCTest

class MovieDetailViewModelTests: XCTestCase {
    var viewModel: MovieDetailViewModel!
    var mockSession: MockURLSession!
    var mockSearchResult: MovieSearchResult!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSession = MockURLSession()
        mockSearchResult = MovieSearchResult(title: "Detail Test", year: "2025", imdbID: "ttDetail", type: "movie", poster: "detail.jpg")
        viewModel = MovieDetailViewModel(mockSearchResult, urlSession: mockSession)
        cancellables = []
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockSession = nil
        mockSearchResult = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    private func mockMovieDetailData(id: String = "ttDetail", title: String = "Test Detail Movie") -> Data? {
        let movieDetail = MoviesModel(
            title: title,
            year: "2025",
            rated: "PG",
            released: "01 Jan 2025",
            runtime: "120 min",
            genre: "Action, Test",
            director: "Test Director",
            writer: "Test Writer",
            actors: "Test Actor One, Test Actor Two",
            plot: "This is a detailed plot for the test movie.",
            language: "English",
            country: "Testland",
            awards: "Nominated for 1 Test Award",
            poster: "http://example.com/poster.jpg",
            imdbRating: "8.5",
            imdbID: id,
            response: "True",
            type: "movie"
        )
        do {
            let encodedData = try JSONEncoder().encode(movieDetail)
            if let jsonString = String(data: encodedData, encoding: .utf8) {
                NSLog("[TEST_DEBUG_HELPER] Generated mock JSON: \(jsonString)")
            }
            return encodedData
        } catch {
            NSLog("[TEST_DEBUG_HELPER] Failed to encode mockMovieDetailData: \(error)")
            return nil
        }
    }

    func testFetchDetails_Success() throws {
        let mockData = mockMovieDetailData()
        mockSession.nextData = mockData
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://www.omdbapi.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let expectation = XCTestExpectation(description: "Movie details fetched")
        viewModel.$movie
            .dropFirst()
            .sink { movieDetail in
                XCTAssertNotNil(movieDetail)
                XCTAssertEqual(movieDetail?.title, "Test Detail Movie")
                XCTAssertEqual(movieDetail?.imdbID, "ttDetail")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        XCTAssertTrue(viewModel.isLoading)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(mockSession.lastURL)
        XCTAssertTrue(mockSession.lastURL?.absoluteString.contains("i=ttDetail") ?? false)
    }

    func testFetchDetails_DecodingError() throws {
        let malformedData = "Not a JSON".data(using: .utf8)
        mockSession.nextData = malformedData
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://www.omdbapi.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let expectation = XCTestExpectation(description: "isLoading becomes false after detail decoding error")

        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(viewModel.movie)
        XCTAssertFalse(viewModel.isLoading)
    }
}
