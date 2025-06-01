# Movies App

## Description

"Movies App is a SwiftUI application for iOS that allows users to browse, search for movies, view detailed information, and manage a list of their favorite films. It utilizes the OMDB API to fetch movie data."

## Features

* View a list of currently popular movies (placeholder, as OMDB has limited support).
* Search for movies by title.
* View detailed information for each movie, including poster, plot, actors, ratings, etc.
* Add movies to a personal "Favorites" list.
* Remove movies from the "Favorites" list.
* Persistent storage of favorites using `UserDefaults`.
* Infinite scrolling/pagination for search results.
* User-friendly interface built with SwiftUI.
* Handles API errors and displays informative messages to the user (e.g., "No movies found," "Too many results").
* Popular movies.(As the API doesnt provide it, it is shown with keyword popular.) 

Main movie listing screen.
Search results screen.
Movie detail screen.
Example: Favorites screen.

## Tech Stack & Tools

* **Framework:** SwiftUI
* **Language:** Swift
* **State Management:** Combine (`@Published`, `ObservableObject`)
* **Networking:** URLSession
* **API:** [OMDb API (The Open Movie Database)](https://www.omdbapi.com/)
* **Persistence:** UserDefaults (for favorites)
* **IDE:** Xcode
* **Testing:** XCTest (Unit Tests and UI Tests)

## API Key Setup

This application uses the OMDb API, which requires an API key.
1.  Visit [https://www.omdbapi.com/apikey.aspx](https://www.omdbapi.com/apikey.aspx) to obtain a free API key.
2.  In the current version of the project, the API key is hardcoded in:
    * `MovieListViewModel.swift`
    * `MovieDetailViewModel.swift`
    Replace the placeholder `"9893379e"` with your own API key in these files:
    ```swift
    private let apiKey = "YOUR_API_KEY_HERE"
    ```
    *(For future development, consider moving the API key to a configuration file or an environment variable for better security and management.)*

## Getting Started / Installation

1.  Clone the repository (if applicable).
2.  Open the `.xcodeproj` file in Xcode.
3.  Ensure you have a valid OMDb API key set up as described above.
4.  Select an iOS Simulator or a connected device.
5.  Build and run the project (Product > Run or `Cmd+R`).

## Project Structure

A brief overview of the main components:
* **Models (`MoviesModel.swift`):** Defines the data structures for movies (e.g., `MoviesModel`, `SearchResponse`, `MovieSearchResult`).
* **ViewModels (`MovieListViewModel.swift`, `MovieDetailViewModel.swift`):** Contains the presentation logic, fetches data from the API, and prepares it for the Views.
* **Views:**
    * `MoviesListScreen.swift`: Main screen for displaying popular movies and search results.
    * `MovieListCard.swift`: Reusable card view for displaying a movie in a list.
    * `MovieDetailScreen.swift`: Screen for displaying detailed information about a selected movie.
    * `FavoritesScreen.swift`: Screen for displaying the list of favorited movies.
    * `NoMoviesFoundView.swift`: Reusable view for displaying error or empty states.
* **Managers (`FavoritesManager.swift`):** Handles the logic for managing favorite movies (adding, removing, persisting).
* **NetworkingProtocols (`NetworkingProtocols.swift`):** Defines protocols for `URLSession` to enable test mocking.
* **Testing Targets:**
    * `MoviesTests`: Contains unit tests for ViewModels and Managers.
        * `MockURLSession.swift`: Mock implementation for `URLSession` for testing.
    * `MoviesUITests`: Contains UI tests for user flows.

## Testing

The project includes:
* **Unit Tests:** Located in the `MoviesTests` target. These tests cover the logic within:
    * `MovieListViewModel` (fetching movies, pagination, search logic).
    * `MovieDetailViewModel` (fetching movie details).
    * `FavoritesManager` (adding, removing, and persisting favorites).
    Unit tests utilize mock `URLSession` objects to ensure reliability and avoid actual network calls.
* **UI Tests:** Located in the `MoviesUITests` target. These tests cover main user flows such as:
    * Searching for movies and viewing details.
    * Adding and removing movies from favorites.
    * Viewing the favorites list.

To run tests:
1.  In Xcode, open the Test Navigator (View > Navigators > Show Test Navigator, or `Cmd+6`).
2.  Click the play button next to the desired test target, test class, or individual test method.
3.  Alternatively, use Product > Test (`Cmd+U`).

## Future Enhancements (Optional)

* Implement a more robust error handling system.
* Add pull-to-refresh functionality.
* Improve UI/UX, add animations.
* Use a more advanced persistence solution like Core Data or Realm for favorites.
* Abstract API key to a configuration file or environment variable.
* Add more detailed UI tests for edge cases.
* Add loading states for images in `MovieListCard` and `MovieDetailScreen`.

## Author

* Kevin M / https://github.com/kevdev161

---
