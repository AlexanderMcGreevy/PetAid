//
//  ClinicView.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import SwiftUI
import CoreLocation

struct ClinicView: View {
    @StateObject private var locationManager = LocationManager()
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
            return clinics.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .reviews:
            return clinics.sorted { ($0.reviewCount ?? 0) > ($1.reviewCount ?? 0) }
        case .distance:
            return clinics.sorted { ($0.distance ?? Double.greatestFiniteMagnitude) < ($1.distance ?? Double.greatestFiniteMagnitude) }
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
                                ClinicCard(clinic: clinic)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Nearby Clinics")
            .onAppear {
                if let location = locationManager.location {
                    fetchClinics(for: location)
                }
            }
            .onChange(of: locationManager.location?.latitude) {
                if let location = locationManager.location {
                    fetchClinics(for: location)
                }
            }

        }
    }

    func fetchClinics(for location: CLLocationCoordinate2D) {
        guard let url = URL(string: "https://petaidcloud.onrender.com/googleplaces") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "location": "\(location.latitude),\(location.longitude)",
            "radius": 5000
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else { return }
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching clinics:", error)
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if let decoded = try? JSONDecoder().decode([Clinic].self, from: data) {
                DispatchQueue.main.async {
                    self.clinics = decoded
                    print("✅ Decoded clinics:", decoded)
                }
            } else {
                print("❌ Failed to decode clinics")
            }
        }.resume()
    }
}
#Preview {
    ClinicView()
}
