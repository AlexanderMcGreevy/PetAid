//
//  FoodViewModel.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import Foundation
import UserNotifications

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
            
            // --- Calculate Days Left ---
            let totalServingsPerDay = max(1, foods[i].assignments.reduce(0) { $0 + $1.servingsPerDay })
            let estimatedDaysLeft = foods[i].totalServings / totalServingsPerDay
            
            // --- Check for warning thresholds ---
            if [7, 1, 0].contains(estimatedDaysLeft) {
                scheduleFoodNotification(for: foods[i], daysLeft: estimatedDaysLeft)
            }
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
    func scheduleFoodNotification(for food: Food, daysLeft: Int) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Food Running Low"
        if daysLeft > 0 {
            content.body = "You have about \(daysLeft) day\(daysLeft == 1 ? "" : "s") of \(food.name) left."
        } else {
            content.body = "You are out of \(food.name)! Please restock."
        }
        content.sound = .default

        // Trigger immediately for testing (you may later use a proper time trigger)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "\(food.id)-\(daysLeft)", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("❌ Notification error:", error.localizedDescription)
            } else {
                print("✅ Notification scheduled for \(daysLeft) days left of \(food.name)")
            }
        }
    }


}
