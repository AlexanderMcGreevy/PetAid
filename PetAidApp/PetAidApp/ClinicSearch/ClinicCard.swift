//
//  ClinicCard.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/30/25.
//

import SwiftUI
struct ClinicCard: View {
    let clinic: Clinic

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(clinic.name)
                .font(.headline)
                .foregroundColor(.black)

            HStack {
                Text("⭐️ \(String(format: "%.1f", clinic.rating ?? 0.0)) | \(clinic.reviewCount ?? 0) reviews")
                Spacer()
                Text("\(String(format: "%.1f", clinic.distance ?? 0.0)) mi")
            }
            .font(.subheadline)
            .foregroundColor(.black)

            Text("Phone: \(clinic.phone ?? "N/A")")
                .font(.footnote)
                .foregroundColor(.black)

            Text("Address: \(clinic.address ?? "N/A")")
                .font(.footnote)
                .foregroundColor(.black)

            Link("View on Google Maps", destination: URL(string: clinic.googleLink ?? "https://maps.google.com")!)
                .font(.footnote)
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 5)
        )
        .padding(.horizontal)
    }
}

