//
//  Food.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import Foundation

struct Food: Identifiable, Codable {
    var id = UUID()
    var name: String
    var totalServings: Int
    var assignments: [PetFoodAssignment] = []
}

struct PetFoodAssignment: Identifiable, Codable {
    var id = UUID()
    var petID: UUID
    var petName: String
    var servingsPerDay: Int
}
