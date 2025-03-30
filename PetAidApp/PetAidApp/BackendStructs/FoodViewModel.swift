//
//  FoodViewModel.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import Foundation
class FoodViewModel: ObservableObject {
    static let shared = FoodViewModel()

    @Published var foods: [Food] = []
    @Published var lastFeedDate: Date? = nil

    let saveKey = "foods.json"

    init() { loadFoods() }

    func addFood(_ food: Food) {
        foods.append(food)
        saveFoods()
    }

    func saveFoods() {
        if let data = try? JSONEncoder().encode(foods) {
            let url = getDocumentsDirectory().appendingPathComponent(saveKey)
            try? data.write(to: url)
        }
    }

    func loadFoods() {
        let url = getDocumentsDirectory().appendingPathComponent(saveKey)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Food].self, from: data) {
            self.foods = decoded
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func feedPets() {
        for i in 0..<foods.count {
            let totalFeed = foods[i].assignments.reduce(0) { $0 + $1.servingsPerDay }
            foods[i].totalServings = max(0, foods[i].totalServings - totalFeed)
        }
        saveFoods()
    }
    
    func autoFeedIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's past 8PM
        if calendar.component(.hour, from: now) >= 20 {
            // Check if we already fed today
            if let last = lastFeedDate, calendar.isDate(last, inSameDayAs: now) {
                return // already fed today
            }
            // Do feed
            feedPets()
            lastFeedDate = now
            print("Auto-fed pets at \(now)")
        }
    }

}
