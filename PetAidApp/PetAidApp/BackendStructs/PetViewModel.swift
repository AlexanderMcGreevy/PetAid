//
//  PetViewModel.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import Foundation
import SwiftUI

class PetViewModel: ObservableObject {
    @Published var pets: [Pet] = []

    let saveKey = "pets.json"
    
    init() {
        loadPets()
    }
    
    func addPet(_ pet: Pet, image: UIImage?) {
        // Save image
        if let image = image {
            saveImage(image, filename: pet.imageFilename)
        }
        
        pets.append(pet)
        savePets()
    }
    
    private func savePets() {
        if let data = try? JSONEncoder().encode(pets) {
            let url = getDocumentsDirectory().appendingPathComponent(saveKey)
            try? data.write(to: url)
        }
    }
    
    private func loadPets() {
        let url = getDocumentsDirectory().appendingPathComponent(saveKey)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Pet].self, from: data) {
            self.pets = decoded
        }
    }
    
    func getImage(for pet: Pet) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(pet.imageFilename)
        return UIImage(contentsOfFile: url.path)
    }
    
    private func saveImage(_ image: UIImage, filename: String) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let url = getDocumentsDirectory().appendingPathComponent(filename)
            try? data.write(to: url)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func deletePet(_ pet: Pet) {
        // Remove from array
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets.remove(at: index)
            savePets()
            
            // Remove the pet's image file too
            let imageURL = getDocumentsDirectory().appendingPathComponent(pet.imageFilename)
            try? FileManager.default.removeItem(at: imageURL)
        }
    }
    
    func updatePet(oldPet: Pet, newPet: Pet, newImage: UIImage?) {
        // Remove the old pet first
        deletePet(oldPet)
        
        // Add the updated pet
        addPet(newPet, image: newImage)
    }



}
