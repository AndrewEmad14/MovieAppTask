import UIKit
import Combine
import SDWebImage
class TopMovieView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
  
    
    @IBOutlet weak var tableView: UITableView!
    
    

    private let viewModel = MoviesViewModel()
    private var cancellables = Set<AnyCancellable>()
    

  
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let retryButton = UIButton(type: .system)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        let nib = UINib(nibName: "TopMovieCustomCellView", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MovieCell")
        bindViewModel()
        viewModel.loadMovies() // Trigger initial data load
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
    
  
    @objc private func retryTapped() {
        viewModel.retryLoading()
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
        cell.movieTitle.text = movie.title
        cell.movieRating.text = String(movie.vote_average ?? 0)
        cell.movieReleaseDate.text = movie.release_date
        cell.rowImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeHolder"))
        cell.favoriteButton.setImage(UIImage(systemName:  "star"), for: .normal)
        return cell
    }
    
  
     func tableView(_ tableView: UITableView, performPrimaryActionForRowAt indexPath: IndexPath) {
         let view = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailScreen") as! MovieDetailsView
        
         view.movie = viewModel.movies[indexPath.row]
         view.viewModel = viewModel
        self.navigationController?.pushViewController(view, animated: true)
    }
}
