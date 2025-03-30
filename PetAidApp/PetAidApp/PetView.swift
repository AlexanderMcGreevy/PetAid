import SwiftUI

struct PetView: View {
    @StateObject var viewModel = PetViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.teal.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(viewModel.pets) { pet in
                            NavigationLink(
                                destination: PetInfoView(
                                    viewModel: viewModel, // <<---- REQUIRED NOW
                                    pet: pet,
                                    image: viewModel.getImage(for: pet)
                                )
                            ) {
                                VStack {
                                    if let image = viewModel.getImage(for: pet) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200)
                                            .cornerRadius(10)
                                            .padding()
                                    } else {
                                        Image("GenericPet")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200)
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
            .navigationTitle("Your Pets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddPet(viewModel: viewModel)) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    PetView()
}
