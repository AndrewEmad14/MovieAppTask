import UIKit
import SDWebImage

class MovieDetailsView: UIViewController {
    
 
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerImageView = UIImageView()
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let metadataStack = UIStackView()
    private let releaseDate = UILabel()
    private let languageLabel = UILabel()
    private let ratingLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let favortieButton = UIButton(type: .system)
    
    
 
    var movie: Movie?
    var viewModel: MoviesViewModel?


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureView()
    }
    

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
      
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never // This is key for ignoring safe area
        view.addSubview(scrollView)
        
      
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerImageView)
        
    
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
     
        titleLabel.numberOfLines = 0
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
       
        metadataStack.axis = .horizontal
        metadataStack.spacing = 16
        metadataStack.distribution = .fillEqually
        metadataStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(metadataStack)
        [releaseDate, languageLabel, ratingLabel].forEach { label in
            label.font = .systemFont(ofSize: 14)
            label.textAlignment = .center
            metadataStack.addArrangedSubview(label)
        }
 
        
      
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel // Better for dark mode support
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
     
        updateFavoriteButtonUI()
        favortieButton.tintColor = UIColor.systemYellow
        
        favortieButton.layer.cornerRadius = 20
        favortieButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(favortieButton)
        
        
        
     
        NSLayoutConstraint.activate([
       
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
          
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 300), // Increased height
            
        
            cardView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -20),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
         
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            metadataStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            metadataStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            metadataStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            metadataStack.heightAnchor.constraint(equalToConstant: 30), // Increased height
            
          
           
            descriptionLabel.topAnchor.constraint(equalTo: metadataStack.bottomAnchor, constant:16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
          
            favortieButton.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            favortieButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:-20),
            favortieButton.widthAnchor.constraint(equalToConstant: 40),
            favortieButton.heightAnchor.constraint(equalToConstant: 40),
            
         
        ])
        
       
        favortieButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        favortieButton.tag = movie?.id ?? 0
    }
    
   
    private func configureView() {
        guard let movie = movie, let viewModel = viewModel else { return }
        
        titleLabel.text = movie.title
        releaseDate.text = movie.release_date ?? ""
        languageLabel.text = movie.original_language ?? ""
        ratingLabel.text = String(movie.vote_average ?? 0)
        descriptionLabel.text = movie.overview ?? ""
        // Load header image - use backdrop_path for header, fallback to poster_path
        let imageUrl = viewModel.getImageUrl(posterPath: movie.poster_path ?? "")
        headerImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "placeHolder"))
    }
    

    @objc func favoriteButtonTapped(_ sender: UIButton) {
        let movieID = sender.tag
        let isFavorite = viewModel?.isFavorite(movieID: movieID) ?? false
        
        let alert = UIAlertController(title: "Confirm Action",
                                          message: "Are you sure you want to remove the movie from your favorites?",
                                          preferredStyle: .alert)

            // OK action
        let okAction = UIAlertAction(title: "OK", style: .default) {[weak self] _ in
            self?.viewModel?.deleteFavorite(movieID: movieID)
            self?.updateFavoriteButtonUI()
        }

            // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                print("User tapped Cancel")
              
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        
        
        
        
        if isFavorite {
            self.present(alert,animated: true, completion:nil)
        } else {
            viewModel?.saveFavorite(movieID: movieID)
        }
        
        updateFavoriteButtonUI()
     
    }
    private func updateFavoriteButtonUI() {
           guard let movieID = movie?.id, let viewModel = viewModel else {
               favortieButton.setImage(UIImage(systemName: "star"), for: .normal)
               return
           }
           let isFavorite = viewModel.isFavorite(movieID: movieID)
        favortieButton.setImage(UIImage(systemName: isFavorite ? "star.fill" : "star"), for: .normal)
    }
 
}
