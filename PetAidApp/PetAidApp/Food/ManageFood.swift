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

                    Button("Feed Pets") {
                        foodVM.feedPets()
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            
        }.environmentObject(foodVM)

    }
}

#Preview {
    ManageFood()
}
