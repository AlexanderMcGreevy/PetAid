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

    // Optional pet to edit
    var petToEdit: Pet? = nil
    var imageToEdit: UIImage? = nil

    @State private var petName: String = ""
    @State private var petAge: String = ""
    @State private var petSpecies: String = ""
    @State private var petBreed: String = ""
    @State private var lastVetVisit: String = ""
    @State private var pastIllnesses: String = ""

    
    @State private var petImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var showSourcePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary

    @Environment(\.presentationMode) var presentationMode

    init(viewModel: PetViewModel, petToEdit: Pet? = nil, imageToEdit: UIImage? = nil) {
        self.viewModel = viewModel
        self.petToEdit = petToEdit
        self.imageToEdit = imageToEdit

        // Pre-fill text fields for editing
        _petName = State(initialValue: petToEdit?.name ?? "")
        _petAge = State(initialValue: petToEdit?.age ?? "")
        _petSpecies = State(initialValue: petToEdit?.species ?? "")
        _petBreed = State(initialValue: petToEdit?.breed ?? "")
        _petImage = State(initialValue: imageToEdit)
        _lastVetVisit = State(initialValue: petToEdit?.lastVetVisit ?? "")
        _pastIllnesses = State(initialValue: petToEdit?.pastIllnesses ?? "")

    }

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
                    .preferredColorScheme(.light)
                    Group {
                        TextField("Last Vet Visit (Date or Notes)", text: $lastVetVisit)
                        TextField("Past Illnesses (Optional)", text: $pastIllnesses)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .preferredColorScheme(.light)


                    // ADD or EDIT Button
                    Button(action: {
                        if let editingPet = petToEdit {
                            // update mode
                            viewModel.updatePet(
                                oldPet: editingPet,
                                newPet: Pet(
                                    name: petName,
                                    age: petAge,
                                    species: petSpecies,
                                    breed: petBreed,
                                    imageFilename: editingPet.imageFilename,
                                    lastVetVisit: lastVetVisit,
                                    pastIllnesses: pastIllnesses
                                ),
                                newImage: petImage
                            )

                        } else {
                            // add mode
                            let newPet = Pet(
                                name: petName,
                                age: petAge,
                                species: petSpecies,
                                breed: petBreed,
                                imageFilename: petToEdit?.imageFilename ?? UUID().uuidString + ".jpg",
                                lastVetVisit: lastVetVisit,
                                pastIllnesses: pastIllnesses
                            )

                            viewModel.addPet(newPet, image: petImage)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(petToEdit == nil ? "Add Pet" : "Save Changes")
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
        .navigationBarTitle(petToEdit == nil ? "Add Pet" : "Edit Pet", displayMode: .inline)
    }
}


#Preview {
    AddPet(viewModel: PetViewModel())
}

