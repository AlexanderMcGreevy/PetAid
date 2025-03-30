//
//  ManageFood.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import SwiftUI

struct ManageFood: View {
    @StateObject var foodVM = FoodViewModel()
    @State private var newFoodName: String = ""
    @State private var totalServings: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.teal.ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Manage Pet Foods")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()

                    HStack {
                        TextField("Food Name", text: $newFoodName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Total Servings", text: $totalServings)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()

                    Button("Add Food") {
                        guard !newFoodName.isEmpty, let servings = Int(totalServings) else { return }
                        foodVM.addFood(Food(name: newFoodName, totalServings: servings))
                        newFoodName = ""
                        totalServings = ""
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Divider().frame(width: UIScreen.main.bounds.width).frame(height: 1).background(Color.white).opacity(0.5)

                    List {
                        ForEach(foodVM.foods) { food in
                            NavigationLink(destination: AssignFoodView(foodVM: foodVM, petVM: PetViewModel(), food: food)) {
                                VStack(alignment: .leading) {
                                    Text(food.name)
                                        .font(.headline)
                                    Text("Servings Left: \(food.totalServings)")
                                    Text("Pets Assigned: \(food.assignments.count)")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)

                    Text("🐾 Pets are fed automatically every day at 8:00 PM.")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.top)
                }
                .padding()
            }
        }
        .environmentObject(foodVM)
    }
    func scheduleFoodNotification(for food: Food, daysLeft: Int) {
        let content = UNMutableNotificationContent()
        content.title = "PetAid Reminder"
        content.body = "You have only \(daysLeft) day\(daysLeft == 1 ? "" : "s") of \(food.name) left!"
        content.sound = .default

        // Schedule immediately (you may later refine this to only schedule once per event)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // <-- test with 5s first

        let request = UNNotificationRequest(identifier: "\(food.id)-\(daysLeft)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled for \(daysLeft) days left")
            }
        }
    }

}

#Preview {
    ManageFood()
}
