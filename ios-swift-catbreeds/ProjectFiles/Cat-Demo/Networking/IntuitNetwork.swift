// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation
import UIKit

/// Network interface
class Network {

    /// Errors from network responses
    ///
    /// - badUrl: URL could not be created
    /// - responseError: The request was unsuccessful due to an error
    /// - responseNoData: The request returned no usable data
    enum NetworkError: Int {
        case badUrl
        case responseError
        case responseNoData
        case decodeError
    }

    private static let imageCache = NSCache<NSString, UIImage>()

    /// Fetch an image from a URL, returning a cached copy if one exists.
    class func fetchImage(from url: URL, completion: @escaping (Swift.Result<UIImage, Error>) -> Void) {
        let cacheKey = url.absoluteString as NSString
        if let cached = imageCache.object(forKey: cacheKey) {
            DispatchQueue.global().async { completion(.success(cached)) }
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else {
                let error = NSError(domain: "Network.fetchImage", code: NetworkError.responseError.rawValue, userInfo: nil)
                return completion(.failure(error))
            }
            guard let data = data, let image = UIImage(data: data) else {
                let error = NSError(domain: "Network.fetchImage", code: NetworkError.responseNoData.rawValue, userInfo: nil)
                return completion(.failure(error))
            }
            imageCache.setObject(image, forKey: cacheKey)
            completion(.success(image))
        }.resume()
    }
    
    /// FetchCatBreeds - retrieve a list of cat breeds from The Cat API
    ///
    /// - Parameter completion: Closure that returns CatBreed on success, an Error on failure
    class func fetchCatBreeds(completion: @escaping (Swift.Result<[CatBreed], Error>) -> Void) {
        
        /// Create the URL for the request
        guard let url = URL(string: "https://api.thecatapi.com/v1/breeds") else {
            let error = NSError(domain: "Network.fetchCats", code: NetworkError.badUrl.rawValue, userInfo: nil)
            return completion(Result.failure(error))
        }
        
        /// Start a data task for the URL
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            /// Check against errors
            guard error == nil else {
                let error = NSError(domain: "Network.fetchCats", code: NetworkError.responseError.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }
            
            /// Check for non-nil response data
            guard let data = data else {
                let error = NSError(domain: "Network.fetchCats", code: NetworkError.responseNoData.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }
            
            do {
                let breeds: [CatBreed]
                
                /// Decode the JSON response into a CatBreed object array
                breeds = try JSONDecoder().decode([CatBreed].self, from: data)
                
                /// Return the data
                completion(.success(breeds))

            } catch {
                /// Unable to decode the response
                let error = NSError(domain: "Network.decode", code: NetworkError.decodeError.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }
        }.resume()
    }
    
    /// Fetch a cat image
    /// - Parameters:
    ///   - breedId: The breed ID (retrieved from the `fetchCatBreeds` call
    ///   - completion: Returns a UIImage or Error
    class func fetchCatImage(breedId: String, completion: @escaping (Swift.Result<UIImage, Error>) -> Void) {
        let breedCacheKey = "breed_\(breedId)" as NSString
        if let cached = imageCache.object(forKey: breedCacheKey) {
            return completion(.success(cached))
        }

        guard let url = URL(string: "https://api.thecatapi.com/v1/images/search?breed_ids=\(breedId)&include_breeds=true") else {
            let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.badUrl.rawValue, userInfo: nil)
            return completion(Result.failure(error))
        }

        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard error == nil else {
                let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.responseError.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }

            guard let data = data else {
                let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.responseNoData.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }

            do {
                let catDetails = try JSONDecoder().decode([CatDetails].self, from: data)

                guard let catDetailImageUrl = catDetails.first?.url else {
                    let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.responseNoData.rawValue, userInfo: nil)
                    return completion(Result.failure(error))
                }

                guard let catImageUrl = URL(string: catDetailImageUrl) else {
                    let error = NSError(domain: "Network.fetchCatDetails", code: NetworkError.responseNoData.rawValue, userInfo: nil)
                    return completion(Result.failure(error))
                }

                fetchImage(from: catImageUrl) { result in
                    if case .success(let image) = result {
                        imageCache.setObject(image, forKey: breedCacheKey)
                    }
                    completion(result)
                }

            } catch {
                let error = NSError(domain: "Network.decode", code: NetworkError.decodeError.rawValue, userInfo: nil)
                return completion(Result.failure(error))
            }

        }.resume()
    }
}
