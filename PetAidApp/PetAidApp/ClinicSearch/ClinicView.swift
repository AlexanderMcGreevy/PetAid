//
//  ClinicView.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import SwiftUI

struct ClinicView: View {
    @State private var clinics: [Clinic] = []
    
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
                    Picker("Sort By", selection: $selectedSort) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
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
            .onAppear(perform: fetchClinics)
        }
    }
    
    func fetchClinics() {
        guard let url = URL(string: "https://petaidcloud.onrender.com/googleplaces") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // ⚠️ TEMP hardcoded location and radius
        let payload: [String: Any] = [
            "location": "40.7128,-74.0060",  // <-- replace later with real location
            "radius": 5000
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else { return }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode([Clinic].self, from: data) else {
                print("Failed to decode or fetch clinics")
                
                
                return
            }
            DispatchQueue.main.async {
                self.clinics = decoded
            }
        }.resume()
    }
}

#Preview {
    ClinicView()
}
