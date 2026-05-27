// Copyright © 2021 Intuit, Inc. All rights reserved.
import UIKit

class DetailViewController: UIViewController {

    var breed: CatBreed?
    
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temparamentLabel: UILabel!
    @IBOutlet weak var lifeSpanLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = breed?.name
        populateData()
        loadCatImage()
        updateFavoriteButton()
    }

    private func updateFavoriteButton() {
        guard let id = breed?.id else { return }
        let isFav = FavoritesManager.shared.isFavorite(id)
        let btn = UIBarButtonItem(
            image: UIImage(systemName: isFav ? "heart.fill" : "heart"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
        btn.tintColor = isFav ? .systemPink : .systemGray
        navigationItem.rightBarButtonItem = btn
    }

    @objc private func toggleFavorite() {
        guard let id = breed?.id else { return }
        FavoritesManager.shared.toggle(id)
        updateFavoriteButton()
    }

    private func populateData() {
        guard let breed = breed else { return }
        descriptionLabel.text = breed.description
        temparamentLabel.text = breed.temperament
        if let lifeSpan = breed.life_span {
            lifeSpanLabel.text = "\(lifeSpan) years"
        }
    }

    private func loadCatImage() {
        activityIndicator.startAnimating()

        let completion: (Swift.Result<UIImage, Error>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                if case .success(let image) = result {
                    self?.catImageView.image = image
                }
            }
        }

        if let imageUrl = breed?.image?.url, let url = URL(string: imageUrl) {
            Network.fetchImage(from: url, completion: completion)
        } else if let breedId = breed?.id {
            Network.fetchCatImage(breedId: breedId, completion: completion)
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
