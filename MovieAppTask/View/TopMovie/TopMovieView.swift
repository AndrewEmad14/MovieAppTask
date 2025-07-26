import UIKit
import Combine
import SDWebImage
class TopMovieView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
  
    
    @IBOutlet weak var tableView: UITableView!
    
    

    private let viewModel = MoviesViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let retryButton = UIButton(type: .system)
    private var currentPageNumber = 1
    private var isFetching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        let nib = UINib(nibName: "TopMovieCustomCellView", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MovieCell")
        // Trigger initial data load
        loadMovie()
        bindViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // Always call the superclass implementation
        // Add your custom code here
        tableView.reloadData() // Refresh the table view to update UI
    }
    func loadMovie(){
        do{
            try viewModel.fetchMoviesFromCoreData(page: currentPageNumber)
            isFetching = false
            return
        }catch{
            print(error)
            viewModel.fetchMoviesFromAPI(page: currentPageNumber)
       }
        
      
      //  CoreDataManager.shared.deleteAllMovies()
     
        
        
    }
    
 
    private func bindViewModel() {

        viewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.retryButton.isHidden = true
            }
            .store(in: &cancellables)
        
   
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.tableView.isHidden = true
                    self?.retryButton.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.tableView.isHidden = false
                    self?.isFetching = false
                    
                }
            }
            .store(in: &cancellables)
        
    
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showErrorAlert(message: errorMessage)
                    self?.retryButton.isHidden = false
                    self?.tableView.isHidden = true
                }
            }
            .store(in: &cancellables)
    }
    
  
    
  
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! TopMovieTableViewCell
        let movie = viewModel.movies[indexPath.row]
        let url = viewModel.getImageUrl(posterPath: movie.poster_path ?? "")
        let isFavorite = viewModel.isFavorite(movieID: movie.id)
        cell.movieTitle.text = movie.title
        cell.movieRating.text = String(movie.vote_average ?? 0)
        cell.movieReleaseDate.text = movie.release_date
        cell.rowImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeHolder"))
        
        cell.favoriteButton.setImage(UIImage(systemName:isFavorite ? "star.fill" : "star"), for: .normal)
        cell.favoriteButton.removeTarget(nil, action: nil, for: .touchUpInside)
        cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        cell.favoriteButton.tag = movie.id
        
        
        
        return cell
        
    }
    @objc func favoriteButtonTapped(_ sender: UIButton) {
        let movieID = sender.tag
        let isFavorite = viewModel.isFavorite(movieID: movieID)
        
        if isFavorite {
            viewModel.deleteFavorite(movieID: movieID)
        } else {
            viewModel.saveFavorite(movieID: movieID)
        }
        
        print("movieId: \(movieID)")
        tableView.reloadData()
    }
  
     func tableView(_ tableView: UITableView, performPrimaryActionForRowAt indexPath: IndexPath) {
         let view = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailScreen") as! MovieDetailsView
        
         view.movie = viewModel.movies[indexPath.row]
         view.viewModel = viewModel
        self.navigationController?.pushViewController(view, animated: true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset

        if distanceFromBottom < height*2 && !isFetching{
            isFetching.toggle()
            currentPageNumber+=1
            loadMovie()
        }
    }
}
