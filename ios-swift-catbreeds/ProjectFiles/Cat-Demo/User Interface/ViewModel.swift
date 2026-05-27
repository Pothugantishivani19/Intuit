// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation
import UIKit

// AnyObject constraint lets catDataDelegate be declared weak, breaking the retain cycle
protocol CatDataDelegate: AnyObject {
    func breedsChangedNotification()
    func imageChangedNotification()
}

class ViewModel {
    weak var catDataDelegate: CatDataDelegate?

    var catBreeds: [CatBreed]? {
        didSet {
            catDataDelegate?.breedsChangedNotification()
        }
    }

    var catImage: UIImage? {
        didSet {
            catDataDelegate?.imageChangedNotification()
        }
    }

    func getBreeds() {
        Network.fetchCatBreeds { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let breeds):
                    self.catBreeds = breeds
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func getCatImage(breedId: String) {
        Network.fetchCatImage(breedId: breedId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.catImage = image
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
