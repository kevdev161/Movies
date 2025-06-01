//
//  MovieListViewModelTests.swift
//  MoviesTests
//
//  Created by Kevin M Jeggy on 01/06/25.
//

import XCTest
import Combine
@testable import Movies

class MovieListViewModelTests: XCTestCase {

    var viewModel: MovieListViewModel!
    var mockSession: MockURLSession!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSession = MockURLSession()
        guard let mockSession = mockSession else {
            XCTFail("mockSession should not be nil")
            return
        }
        viewModel = MovieListViewModel(urlSession: mockSession)
        cancellables = []
    }


    override func tearDownWithError() throws {
        viewModel = nil
        mockSession = nil
        cancellables = nil
        try super.tearDownWithError()
    }
    
    func mockSearchResponseData(movies: [MovieSearchResult] = [], totalResults: String = "0") -> Data? {
        let response = SearchResponse(search: movies, totalResults: totalResults, response: "True")
        return try? JSONEncoder().encode(response)
    }

    func testFetchPopularMovies_Success() throws {
        let mockMovie = MovieSearchResult(title: "Popular Test Movie", year: "2025", imdbID: "tt123", type: "movie", poster: "poster.jpg")
        let mockData = mockSearchResponseData(movies: [mockMovie], totalResults: "1")
        mockSession.nextData = mockData
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://www.omdbapi.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let expectation = XCTestExpectation(description: "Popular movies fetched")
        viewModel.$popularMovies
            .dropFirst()
            .sink { movies in
                XCTAssertEqual(movies.count, 1)
                XCTAssertEqual(movies.first?.title, "Popular Test Movie")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        XCTAssertTrue(viewModel.isLoading)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFetchMovies_Success_FirstPage() throws {
        viewModel.searchText = "TestSearch"
        let mockMovie = MovieSearchResult(title: "Searched Test Movie", year: "2025", imdbID: "tt456", type: "movie", poster: "poster_s.jpg")
        let mockData = mockSearchResponseData(movies: [mockMovie], totalResults: "15")
        mockSession.nextData = mockData
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://www.omdbapi.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let expectation = XCTestExpectation(description: "Movies fetched")
        viewModel.$movies
            .dropFirst(2)
            .sink { movies in
                if !movies.isEmpty {
                    XCTAssertEqual(movies.count, 1)
                    XCTAssertEqual(movies.first?.title, "Searched Test Movie")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.movies.count, 1)
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(viewModel.totalResults, 15)
        XCTAssertNotNil(mockSession.lastURL)
        XCTAssertTrue(mockSession.lastURL?.absoluteString.contains("s=TestSearch&page=1") ?? false)
    }

    func testFetchMovies_Success_NoMorePages() throws {
        viewModel.searchText = "TestSinglePage"
        let mockMovie = MovieSearchResult(title: "Single Page Movie", year: "2025", imdbID: "tt789", type: "movie", poster: "poster_sp.jpg")
        
        let mockData = mockSearchResponseData(movies: [mockMovie], totalResults: "1")
        mockSession.nextData = mockData
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://www.omdbapi.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let expectation = XCTestExpectation(description: "Single page movies fetched")
        viewModel.$movies
            .dropFirst(2)
            .sink { movies in
                if !movies.isEmpty {
                    XCTAssertEqual(movies.count, 1)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertEqual(viewModel.currentPage, 1)
    }

    func testFetchMovies_DecodingError() throws {
        viewModel.searchText = "TestDecodeError"
        let malformedData = "Not a JSON".data(using: .utf8)
        mockSession.nextData = malformedData
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://www.omdbapi.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let expectation = XCTestExpectation(description: "isLoading becomes false after decoding error")
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(viewModel.movies.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testResetSearch() {
        viewModel.movies = [MovieSearchResult(title: "Old Movie", year: "2000", imdbID: "tt000", type: "movie", poster: "old.jpg")]
        viewModel.currentPage = 5
        viewModel.totalResults = 50
        viewModel.hasMorePages = true
        viewModel.searchText = "OldSearch"
        
        let expectation = XCTestExpectation(description: "fetchMovies called by resetSearch")
        mockSession.nextData = mockSearchResponseData()
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://www.omdbapi.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
         viewModel.$movies
            .dropFirst(1)
            .sink { _ in
                if self.viewModel.isLoading == false {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "NewSearch"
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(viewModel.movies.isEmpty)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertEqual(viewModel.totalResults, 0)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertTrue(mockSession.lastURL?.absoluteString.contains("s=NewSearch&page=1") ?? false)
    }

    func testSearchText_DidSet_ResetsWhenCountGreaterThanTwo() {
        let expectation = XCTestExpectation(description: "fetchMovies called due to searchText change")
        mockSession.nextData = mockSearchResponseData()
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://www.omdbapi.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        var isLoadingSequence: [Bool] = []
        viewModel.$isLoading
            .sink { loading in
                isLoadingSequence.append(loading)
                if isLoadingSequence == [false, true, false] || isLoadingSequence == [true, false] {
                    expectation.fulfill()
                } else if isLoadingSequence.count > 1 && isLoadingSequence.last == false {
                     expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.searchText = "tes"
        wait(for: [expectation], timeout: 2.0)
        XCTAssertNotNil(mockSession.lastURL, "fetchMovies should have been called")
        XCTAssertTrue(mockSession.lastURL?.absoluteString.contains("s=tes&page=1") ?? false)
    }

    func testSearchText_DidSet_DoesNotResetWhenCountLessThanThree() {
        var fetchMoviesCalled = false

        viewModel.searchText = "te"
        let expectation = XCTestExpectation(description: "Short delay to check if fetchMovies was called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)

        XCTAssertNil(mockSession.lastURL, "fetchMovies should NOT have been called for searchText 'te'")
    }
}
