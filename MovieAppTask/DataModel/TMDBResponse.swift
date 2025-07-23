//
//  TMDBResponse.swift
//  MovieAppTask
//
//  Created by Andrew Emad Morris on 22/07/2025.
//


struct TMDBResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}