//
//  CoreDataManager.swift
//  MovieAppTask
//
//  Created by Andrew Emad Morris on 24/07/2025.
//


import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "MovieAppTask")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveMovies(_ movies: [Movie], page: Int) {
        let context = self.context
        for movie in movies {
            let movieEntity = MovieDB(context: context)
            movieEntity.id = Int32(movie.id)
            movieEntity.title = movie.title
            movieEntity.overview = movie.overview
            movieEntity.poster_path = movie.poster_path
            movieEntity.release_date = movie.release_date
            movieEntity.vote_average = movie.vote_average ?? 0.0
            movieEntity.pageNumber =   Int32(page)

        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save movies: \(error)")
        }
    }
    
    func saveFavoirte(moiveID:Int){
        let context = self.context
        let favoriteDB = FavoriteDB(context: context)
        favoriteDB.movieID = Int32(moiveID)
        favoriteDB.favorite = true
        do{
            try context.save()
        }catch{
            print("Failed to save to favorites: \(error)")
        }
        
    }
    func isFavortie(movieID:Int)->Bool{
        let request: NSFetchRequest<NSFetchRequestResult> = FavoriteDB.fetchRequest()
        request.predicate = NSPredicate(format: "movieID == %d",movieID)
        do{
            let count = try context.count(for: request)
            if count > 0 {
                return true
            } else {
                return false
            }
        }catch{print("Failed to fetch : \(error)")}
        return false
    }
    func deleteFavorte(movieID:Int){
        let request: NSFetchRequest<NSFetchRequestResult> = FavoriteDB.fetchRequest()
        request.predicate = NSPredicate(format: "movieID == %d",movieID)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete movies: \(error)")
        }
    }
    
    func fetchMovies(page: Int) throws -> [MovieDB] {
        let request: NSFetchRequest<MovieDB> = MovieDB.fetchRequest()
        request.predicate = NSPredicate(format: "pageNumber == %d", page)
        
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
       
             let movies = try context.fetch(request)
            if movies.isEmpty{
                throw CoreDataError.emptyPage
            }else{
                return movies
            }
        
    }
    
    func deleteAllMovies() {
        let request: NSFetchRequest<NSFetchRequestResult> = MovieDB.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete movies: \(error)")
        }
    }
    enum CoreDataError: Error, LocalizedError {
        case emptyPage
        
        
        var errorDescription: String? {
            switch self {
            case .emptyPage:
                return "Empty page"
           
            }
        }
    }
}
