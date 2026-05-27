// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation

/// Data Model for network response
struct CatBreed: Decodable {
    /// internal ID
    let id: String?
    
    /// Name of cat (e.g. "Somali")
    let name: String?
    
    /// Description
    let description: String?
    
    /// Simple phrase describing cat - ex. "Active, energetic, independent, intelligent, gentle"
    let temperament: String?
    
    /// Range (e.g. 12-16)
    let life_span: String?
    
    /// Reference
    let wikipedia_url: String?
    
    /// Traits (0 or 1)
    let experimental: Int?
    let hairless: Int?
    let indoor: Int?
    let lap: Int?
    let hypoallergenic: Int?
    let rare: Int?
    let natural: Int?
    
    /// Characteristic rankings (0 to 5)
    let adaptability: Int?
    let affection_level: Int?
    let child_friendly: Int?
    let dog_friendly: Int?
    let energy_level: Int?
    let grooming: Int?
    let health_issues: Int?
    let intelligence: Int?
    let shedding_level: Int?
    let social_needs: Int?
    let stranger_friendly: Int?
    let vocalisation: Int?
    
    struct CatImage: Decodable {
        let id: String?             // "k71ULYfRr"
        let width: Int?             // 2048
        let height: Int?            // 1554
        let url: String?            // "https://cdn2.thecatapi.com/images/k71ULYfRr.jpg"
    }
    
    let origin: String?
    let country_code: String?
    let reference_image_id: String?
    let image: CatImage?
}

struct CatDetails: Decodable {
    let breeds: [CatBreedDetails]?
    
    struct CatBreedDetails: Decodable {
        let id: String?
        let name: String?
        let temperament: String?
    }
    
    let url: String?    // image URL
}
