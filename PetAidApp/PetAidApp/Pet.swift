//
//  Pet.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import Foundation
import SwiftUI

struct Pet: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var age: String
    var species: String
    var breed: String
    var imageFilename: String // filename saved in documents directory
}
