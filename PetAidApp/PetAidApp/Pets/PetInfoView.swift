//
//  PetInfoView.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import SwiftUI

struct PetInfoView: View {
    @State private var isEditing = false
    @ObservedObject var viewModel: PetViewModel
    let pet: Pet
    let image: UIImage?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color.teal.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .cornerRadius(20)
                    }
                    
                    Text(pet.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Species: \(pet.species)")
                        Text("Breed: \(pet.breed)")
                        Text("Age: \(pet.age)")
                        Text("Last Vet Visit: \(pet.lastVetVisit.isEmpty ? "N/A" : pet.lastVetVisit)")
                        Text("Past Illnesses: \(pet.pastIllnesses.isEmpty ? "None" : pet.pastIllnesses)")

                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    //Edit Button
                    Button("Edit Pet") {
                        isEditing = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .navigationDestination(isPresented: $isEditing) {
                        AddPet(viewModel: viewModel, petToEdit: pet, imageToEdit: image)
                    }
                    
                    //Delete Button
                    Button(action: {
                        viewModel.deletePet(pet)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Delete Pet")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(12)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle(pet.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    PetInfoView(
        viewModel: PetViewModel(),
        pet: Pet(
            name: "Buddy",
            age: "3",
            species: "Dog",
            breed: "Golden Retriever",
            imageFilename: "dummy.jpg",
            lastVetVisit: "01/01/2025",
            pastIllnesses: "None"
        ),
        image: UIImage(named: "GenericPet")
    )
}

