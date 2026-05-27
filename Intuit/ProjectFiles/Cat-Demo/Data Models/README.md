//
//  CatModels.swift
//  Cat Demo
//
//  Created by Intuit on 2021-07-19.
//

import Foundation

struct CatBreed: Decodable, Identifiable, Equatable {
    let id: String
    let name: String
    let origin: String?
    let description: String?
    let temperament: String?
    let lifeSpan: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case origin
        case description
        case temperament
        case lifeSpan = "life_span"
    }
}

struct CatDetails: Decodable, Equatable {
    let id: String
    let url: URL?
    let width: Int?
    let height: Int?
    let breeds: [CatBreed]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case width
        case height
        case breeds
    }
}

struct CatImage: Decodable {
    let id: String
    let url: URL?
    let width: Int?
    let height: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case width
        case height
    }
}
