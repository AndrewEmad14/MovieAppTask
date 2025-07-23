//
//  TopMovieTableViewCell.swift
//  MovieAppTask
//
//  Created by Andrew Emad Morris on 22/07/2025.
//

import UIKit

class TopMovieTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func addToFavorites(_ sender: Any) {
    }
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var rowImage: UIImageView!
    
    @IBOutlet weak var movieReleaseDate: UILabel!
    @IBOutlet weak var movieRating: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
