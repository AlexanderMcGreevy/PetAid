//
//  IllnessPets.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import SwiftUI

struct IllnessPets: View {
    @StateObject var viewModel = PetViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.teal.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(viewModel.pets) { pet in
                            NavigationLink(
                                destination: IllnessView(pet: pet)
                            ) {
                                VStack {
                                    if let image = viewModel.getImage(for: pet) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(10)
                                            .padding()
                                    } else {
                                        Image("GenericPet")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .padding()
                                    }
                                    Text(pet.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Diagnose Pet").preferredColorScheme(.dark)
        }
    }
}

#Preview {
    IllnessPets()
}
