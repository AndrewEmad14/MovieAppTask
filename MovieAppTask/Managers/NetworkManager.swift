//
//  NetworkManager.swift
//  MovieAppTask
//
//  Created by Andrew Emad Morris on 21/07/2025.
//

import Foundation
import Combine

class NetworkManager{
    static let sharedInstance  = NetworkManager()
    private let  baseURL = "https://api.themoviedb.org/3/movie"
    private var apiKey = ""
    private let session = URLSession.shared
    private init(){}
    func fetchTopMovies(page : Int)->AnyPublisher<[Movie], NetworkError>{
        let baseUrl = "\(baseURL)/top_rated"
        setAPIKey()
        guard let url = createMovieListUrl(baseURL: baseUrl,page:page)else{
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "Bearer \(apiKey)"
        ]
        return session
            .dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response -> Data in
                try self?.validateResponse(response) ?? ()
                if let jsonString = String(data: data, encoding: .utf8) {
                                    print("Raw JSON: \(jsonString)")
                                }
                return data
            }
            .decode(type: TMDBResponse.self , decoder: JSONDecoder())
            .map{ response in
                Array(response.results)
            }
            .mapError { error -> NetworkError in
                            if let networkError = error as? NetworkError {
                                return networkError
                            } else if error is DecodingError {
                                return NetworkError.decodingError
                            } else {
                                return NetworkError.networkError(error)
                            }
                        }
                        
                      
                        .receive(on: DispatchQueue.main)
                        
        
                        .eraseToAnyPublisher()
    }
 
    private func setAPIKey(){
        do{
            self.apiKey = try KeychainManager.retrieveAPIKey(service: "TMBD_key") ?? ""

        }catch{
            print(error)
            
        }
    }
    private func createMovieListUrl(baseURL : String,page: Int) -> URL? {
            var components = URLComponents(string: "\(baseURL)")
            components?.queryItems = [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: String(page))
            ]
            return components?.url
    }

    private func validateResponse(_ response: URLResponse) throws {
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError(URLError(.badServerResponse))
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                
                throw NetworkError.serverError(httpResponse.statusCode)
            }
        }
    func getImageUrl(posterPath : String)->String{
        return "https://image.tmdb.org/t/p/w185\(posterPath)"
    }
    enum NetworkError: Error, LocalizedError {
        case invalidURL
        case noData
        case decodingError
        case serverError(Int)
        case networkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode response"
            case .serverError(let code):
                return "Server error with code: \(code)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
}
