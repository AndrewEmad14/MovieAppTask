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
    
    // Store cancellables to manage memory
    private var cancellables = Set<AnyCancellable>()
    private let tmdbService = NetworkManager.sharedInstance
    
    init() {
        loadMovies()
    }
    
    func loadMovies() {
        // Set loading state
        isLoading = true
        errorMessage = nil
        
        // Call our service method that returns a publisher
        tmdbService.fetchTopMovies()
            
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
                        self?.movies = movies
                    }
                }
            )
            // Store the cancellable to prevent the subscription from being deallocated
            .store(in: &cancellables)
    }
    func getImageUrl(posterPath:String)->String{
        return NetworkManager.sharedInstance.getImageUrl(posterPath: posterPath)
    }
    func retryLoading() {
        loadMovies()
    }
}
