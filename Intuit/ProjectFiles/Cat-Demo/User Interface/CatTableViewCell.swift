//
//  CatTableViewCell.swift
//  Cat-Demo
//
//  Created by bhavani pothuganti on 5/27/26.
//

import UIKit

class CatTableViewCell: UITableViewCell {
    
    private var breedId: String?
    
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var catTitleLabel: UILabel!
    @IBOutlet weak var catDescriptionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
    }
    
    @IBAction func didTapFavorite(_ sender: UIButton) {
        sender.isSelected.toggle()
        if let breedId {
            FavoritesManager.shared.toggle(breedId)
        }
    }
    
    func populateWith(breed: CatBreed) {
        catTitleLabel.text = breed.name
        catDescriptionLabel.text = breed.description
//        if let breedId = breed.id {
//            Network.fetchCatImage(breedId: breedId) { result in
//                if case let .success(fetchedImage) = result {
//                    DispatchQueue.main.async { [weak self] in
//                        self?.catImageView.image = fetchedImage
//                    }
//                }
//            }
//        }
        
        breedId = breed.id
        if let id = breed.id, FavoritesManager.shared.isFavorite(id) {
            favoriteButton.isSelected = true
        } else {
            favoriteButton.isSelected = false
        }
    }

}
