//
//  Clinic.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import Foundation

struct Clinic: Identifiable, Codable {
    var id = UUID()
    let name: String
    let rating: Double
    let reviewCount: Int
    let distance: Double // in miles or km (dont know yet)
    let phone: String
    let address: String
    let googleLink: String
}
