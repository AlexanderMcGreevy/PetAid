//
//  ClinicView.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import SwiftUI

struct ClinicView: View {
    // Dummy data for testing, replace with actual JSON loading later
    @State private var clinics: [Clinic] = [
        Clinic(name: "Happy Paws Vet", rating: 4.7, reviewCount: 120, distance: 2.5, phone: "555-234-1234", address: "123 Pet St", googleLink: "https://maps.google.com"),
        Clinic(name: "Animal Health Center", rating: 4.5, reviewCount: 80, distance: 1.2, phone: "555-343-5678", address: "456 Animal Rd", googleLink: "https://maps.google.com"),
        Clinic(name: "Best Friends Clinic", rating: 4.9, reviewCount: 200, distance: 3.0, phone: "555--234-9012", address: "789 Vet Ln", googleLink: "https://maps.google.com")
    ]
    
    enum SortOption: String, CaseIterable {
        case rating = "Rating"
        case reviews = "Reviews"
        case distance = "Distance"
    }
    
    @State private var selectedSort: SortOption = .rating
    
    var sortedClinics: [Clinic] {
        switch selectedSort {
        case .rating:
            return clinics.sorted { $0.rating > $1.rating }
        case .reviews:
            return clinics.sorted { $0.reviewCount > $1.reviewCount }
        case .distance:
            return clinics.sorted { $0.distance < $1.distance }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.teal.ignoresSafeArea()
                
                VStack {
                    // Sort Picker
                    Picker("Sort By", selection: $selectedSort) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Clinic List
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(sortedClinics) { clinic in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(clinic.name)
                                        .font(.headline)
                                    
                                    HStack {
                                        Text("⭐️ \(String(format: "%.1f", clinic.rating)) | \(clinic.reviewCount) reviews")
                                        Spacer()
                                        Text("\(String(format: "%.1f", clinic.distance)) mi")
                                    }
                                    
                                    Text("Phone: \(clinic.phone)")
                                    Text("Address: \(clinic.address)")
                                    
                                    Link("View on Google Maps", destination: URL(string: clinic.googleLink)!)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Nearby Clinics")
        }
    }
}

#Preview {
    ClinicView()
}
