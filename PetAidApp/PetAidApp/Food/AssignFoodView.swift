//
//  AssignFoodView.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import SwiftUI

struct AssignFoodView: View {
    @ObservedObject var foodVM: FoodViewModel
    @ObservedObject var petVM: PetViewModel

    var food: Food

    @State private var servingsPerDay: [UUID: String] = [:]

    var body: some View {
        ZStack {
            Color.teal.ignoresSafeArea()
            VStack {
                Text("Assign \(food.name) to Pets")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)
                Text("🐾 Click Back when finished")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.bottom)
                List {
                    ForEach(petVM.pets) { pet in
                        LazyVStack(alignment: .leading) {
                            Text(pet.name)
                            HStack {
                                Text("Servings per Day:")
                                TextField("0", text: Binding(
                                    get: { servingsPerDay[pet.id] ?? "" },
                                    set: { servingsPerDay[pet.id] = $0 }
                                ))
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }.cornerRadius(12)
                }.listStyle(.plain).padding()
                
                Button("Save Assignments") {
                    assignPets()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            
        }
        
    }

    func assignPets() {
        guard let index = foodVM.foods.firstIndex(where: { $0.id == food.id }) else { return }

        var assignments: [PetFoodAssignment] = []

        for pet in petVM.pets {
            if let servingsString = servingsPerDay[pet.id],
               let servings = Int(servingsString),
               servings > 0 {
                let assignment = PetFoodAssignment(petID: pet.id, petName: pet.name, servingsPerDay: servings)
                assignments.append(assignment)
            }
        }

        foodVM.foods[index].assignments = assignments
        foodVM.saveFoods()
    }
}


#Preview {
    AssignFoodView(
        foodVM: FoodViewModel(),
        petVM: PetViewModel(),
        food: Food(name: "SampleFood", totalServings: 10)
    )
}
