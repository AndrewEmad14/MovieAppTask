//
//  Movie.swift
//  MovieAppTask
//
//  Created by Andrew Emad Morris on 21/07/2025.
//

//Poster
//Title
//Rating
//ReleaseDate
//Overview
//Vote Average
//Original Language
//Favorite/Unfavorite button
struct Movie : Codable{
    var id : Int
    var original_language : String?
    var overview : String?
    var poster_path : String?
    var release_date : String?
    var title : String?
    var vote_average : Double?
  
}
