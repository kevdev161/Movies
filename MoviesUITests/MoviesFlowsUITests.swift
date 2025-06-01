//
//  MoviesFlowsUITests.swift
//  MoviesUITests
//
//  Created by Kevin M Jeggy on 01/06/25.
//

import XCTest

final class MoviesFlowsUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    func testInitialScreen_DisplaysPopularMovies() throws {
        XCTAssertTrue(app.staticTexts["Popular movies"].waitForExistence(timeout: 5), "Popular movies title should be visible.")
        
        XCTAssertTrue(app.scrollViews.firstMatch.waitForExistence(timeout: 5))
    }

    func testSearchForMovie_AndNavigateToDetail() throws {
        let searchField = app.textFields["movieSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))

        searchField.tap()
        searchField.typeText("Prisoners\n")
        let firstMovieTitle = app.staticTexts
            .containing(NSPredicate(format: "label BEGINSWITH[c] %@", "Prisoners"))
            .firstMatch
        firstMovieTitle.tap()
        
        let detailTitle = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH[c] %@", "Prisoners")).firstMatch
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 5), "Movie detail screen should show the movie title.")
        
        let addToFavoritesButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Add to favorites")).firstMatch
        XCTAssertTrue(addToFavoritesButton.waitForExistence(timeout: 2), "Add to favorites button should be visible.")
    }

    func testAddAndRemoveFavoriteFromDetailScreen() throws {
        let searchField = app.textFields["movieSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("Inception\n")

        let movieTitleInList = app.staticTexts.containing(.init(format: "Title BEGINSWITH[c] %@", "Inception")).firstMatch
        XCTAssertTrue(movieTitleInList.waitForExistence(timeout: 10), "Inception should appear in search results.")
        let inceptionImdbID = "tt1375666"
        movieTitleInList.tap()
        
        let addToFavoritesButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Add to favorites")).firstMatch
        XCTAssertTrue(addToFavoritesButton.waitForExistence(timeout: 5), "Add to favorites button should exist.")
        addToFavoritesButton.tap()

        let removeFromFavoritesButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Remove from favorites")).firstMatch
        XCTAssertTrue(removeFromFavoritesButton.waitForExistence(timeout: 2), "Button should now say 'Remove from favorites'.")
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        let mainFavoritesHeartIcon = app.images.firstMatch
        let favoritesNavButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "")).allElementsBoundByIndex.first { $0.images.count > 0 }

        if let favButton = favoritesNavButton, favButton.waitForExistence(timeout: 2) {
            favButton.tap()
        } else {
            let heartIcon = app.images.matching(identifier: "heart.fill").firstMatch
             app.buttons["navigateToFavoritesScreen"].tap()
        }
        
        XCTAssertTrue(app.navigationBars["Favorites"].waitForExistence(timeout: 2), "Should be on Favorites screen.")
        let favoritedMovieTitle = app.staticTexts.containing(.init(format: "Title ==[c] %@", "Inception")).firstMatch
        XCTAssertTrue(favoritedMovieTitle.waitForExistence(timeout: 5), "Inception should be in favorites.")
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        if !searchField.exists {
             app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        if !searchField.isHittable { searchField.tap() }
        if let currentText = searchField.value as? String, !currentText.isEmpty {
            searchField.buttons["Clear text"].tap()
        }
        searchField.typeText("Inception\n")

        XCTAssertTrue(movieTitleInList.waitForExistence(timeout: 10))
        movieTitleInList.tap()
        
        XCTAssertTrue(removeFromFavoritesButton.waitForExistence(timeout: 5))
        removeFromFavoritesButton.tap()

        let newAddToFavoritesButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Add to favorites")).firstMatch
        XCTAssertTrue(newAddToFavoritesButton.waitForExistence(timeout: 2), "Button should now say 'Add to favorites' again.")
    }
    
    func testSearchForNonExistentMovie_ShowsNoMoviesFoundView() {
        let searchField = app.textFields["movieSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))

        searchField.tap()
        searchField.typeText("NonExistentMovieWithAReallyLongNameThatShouldNotExist123\n")
        
        XCTAssertTrue(app.staticTexts["No Movies Found"].waitForExistence(timeout: 10), "'No Movies Found' text should appear.")
        XCTAssertTrue(app.staticTexts["Try a different search or check your spelling."].waitForExistence(timeout: 2))
    }
}

extension XCUIElement {
    func forceTap() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            coordinate.tap()
        }
    }
}
