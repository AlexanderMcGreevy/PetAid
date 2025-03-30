//
//  Clinic.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import Foundation

struct Clinic: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let rating: Double
    let reviewCount: Int
    let distance: Double
    let phone: String
    let address: String
    let googleLink: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case rating
        case reviewCount = "review_count"
        case distance
        case phone
        case address
        case googleLink = "google_link"
    }
}
