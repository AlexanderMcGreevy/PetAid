//
//  AddPet.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import SwiftUI
import PhotosUI

struct AddPet: View {
    @ObservedObject var viewModel: PetViewModel
    
    @State private var petName: String = ""
    @State private var petAge: String = ""
    @State private var petSpecies: String = ""
    @State private var petBreed: String = ""
    
    @State private var petImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var showSourcePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(.teal).ignoresSafeArea()
            ScrollView {
                LazyVStack {
                    if let petImage = petImage {
                        Image(uiImage: petImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .padding()
                    } else {
                        Text("No image selected")
                            .foregroundColor(.white)
                    }
                    
                    Button("Upload Pet Photo") {
                        showSourcePicker = true
                    }
                    .actionSheet(isPresented: $showSourcePicker) {
                        ActionSheet(
                            title: Text("Select Photo Source"),
                            buttons: [
                                .default(Text("Camera")) {
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        imagePickerSource = .camera
                                        isShowingImagePicker = true
                                    } else {
                                        print("Camera not available on this device.")
                                    }
                                },
                                .default(Text("Photo Library")) {
                                    imagePickerSource = .photoLibrary
                                    isShowingImagePicker = true
                                },
                                .cancel()
                            ]
                        )
                    }
                    .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(sourceType: imagePickerSource) { image in
                            self.petImage = image
                        }
                    }
                    
                    Group {
                        TextField("Pet Name", text: $petName)
                        TextField("Age", text: $petAge)
                        TextField("Species", text: $petSpecies)
                        TextField("Breed", text: $petBreed)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    
                    Button(action: {
                        let newPet = Pet(
                            name: petName,
                            age: petAge,
                            species: petSpecies,
                            breed: petBreed,
                            imageFilename: UUID().uuidString + ".jpg"
                        )
                        viewModel.addPet(newPet, image: petImage)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Add Pet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
            }
        }
        .navigationBarTitle("Add Pet", displayMode: .inline)
    }
}


#Preview {
    AddPet(viewModel: PetViewModel())
}

