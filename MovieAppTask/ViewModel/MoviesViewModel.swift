//
//  MoviesViewModel.swift
//  MovieAppTask
//
//  Created by Andrew Emad Morris on 22/07/2025.
//
import Combine
import Foundation

class MoviesViewModel: ObservableObject {
    // @Published creates a publisher that emits whenever the property changes
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var pageNumber = 1
    // Store cancellables to manage memory
    private var cancellables = Set<AnyCancellable>()
    private let tmdbService = NetworkManager.sharedInstance
    
    
    
    func fetchMoviesFromAPI(page:Int) {
        // Set loading state
        isLoading = true
        errorMessage = nil
        pageNumber = page
        // Call our service method that returns a publisher
        tmdbService.fetchTopMovies(page: page)
            
            // sink creates a subscriber that handles both success and failure
            .sink(
                receiveCompletion: { [weak self] completion in
                    // This closure handles the completion event
                    DispatchQueue.main.async {
                        self?.isLoading = false
                    }
                    
                    // Check if completion contains an error
                    if case .failure(let error) = completion {
                        DispatchQueue.main.async {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] movies in
                    // This closure handles successfully received values
                    DispatchQueue.main.async {
                        self?.movies.append(contentsOf: movies) 
                        CoreDataManager.shared.saveMovies(movies, page: self?.pageNumber ?? 1)
                    }
                }
            )
            // Store the cancellable to prevent the subscription from being deallocated
            .store(in: &cancellables)
    }
    func fetchMoviesFromCoreData(page : Int) throws {
        let movieEntityList = try CoreDataManager.shared.fetchMovies(page: page)
        movieEntityList.forEach { movie in
            movies.append(Movie(id: Int(movie.id), original_language:  movie.original_language, overview: movie.overview, poster_path: movie.poster_path, release_date: movie.release_date, title: movie.title, vote_average: movie.vote_average))
        }
    }
    func saveMoviesInCoreData(){
        CoreDataManager.shared.saveMovies(movies, page: pageNumber)
    }
    func getImageUrl(posterPath:String)->String{
        return NetworkManager.sharedInstance.getImageUrl(posterPath: posterPath)
    }
 
}
