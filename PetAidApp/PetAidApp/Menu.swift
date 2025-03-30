//
//  ContentView.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import SwiftUI

struct Menu: View {
    @State private var scale = 0.5
    @ObservedObject var foodVM = FoodViewModel.shared


    var body: some View {
        NavigationView {
            ZStack {
                Color(.teal)
                LazyVStack {
                    Image("WhiteLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 350)
                        .padding(.bottom, 20)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                scale = 1.0
                            }
                        }
                        .scaleEffect(scale).padding(.top, 20)
                    
                    LazyVStack {
                        NavigationLink(destination: PetView()) {
                            Text("Manage Pets")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .animation(.easeInOut, value: scale)

                        }.padding()
                        
                        NavigationLink(destination: IllnessPets()) {
                            Text("Identify Illness")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .animation(.easeInOut, value: scale)

                        }.padding()
                        
                        
                        NavigationLink(destination: ClinicView()) {
                            Text("Find Clinics")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .animation(.easeInOut, value: scale)
                        }.padding()
                        
                        NavigationLink(destination: ManageFood()) {
                            Text("Manage Food")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .animation(.easeInOut, value: scale)

                        }.padding()
                    }
                    .padding(.bottom, 150)
                }
            }
            .edgesIgnoringSafeArea(.all).onAppear {
                foodVM.autoFeedIfNeeded()
            }

        }
    }
}

#Preview {
    Menu()
}
