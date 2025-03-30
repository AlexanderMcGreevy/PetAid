//
//  IllnessView.swift
//  PetAidApp
//
//  Created by Alexander McGreevy on 3/29/25.
//

import SwiftUI

struct IllnessView: View {
    @State private var description: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    
    @State private var diagnosis: String? = nil // response
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    
    var body: some View {
        ZStack {
            Color.teal.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("PetAid Diagnosis")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                Text("Please describe your pet's symptoms in as much detail as possible and include an image if needed:")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                // Text Input
                TextEditor(text: $description)
                    .frame(height: 150)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .padding()
                
                // Optional Image Upload
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(10)
                }
                Button("Upload Optional Image") {
                    isShowingImagePicker = true
                }
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(sourceType: .photoLibrary) { image in
                        selectedImage = image
                    }
                }
                
                // Send to Flask Button
                Button(action: sendToBackend) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Send for Diagnosis")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                // Diagnosis Display
                if let diagnosis = diagnosis {
                    Text("Diagnosis: \(diagnosis)")
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        if let errorMessage = errorMessage {
            Text("Error: \(errorMessage)")
                .foregroundColor(.red)
        }

    }
    
    // MARK: Networking
    func sendToBackend() {
        guard !description.isEmpty else { return }
        isLoading = true
        
        // Create JSON Payload
        var payload: [String: Any] = ["description": description]
        
        if let image = selectedImage {
            let resized = resizeImage(image: image, targetWidth: 640)
            if let compressed = resized.jpegData(compressionQuality: 0.6) {
                let base64Image = compressed.base64EncodedString()
                payload["image"] = base64Image
            }
        }
        

        
        // Convert to JSON Data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("Failed to encode JSON")
            isLoading = false
            return
        }
        
        // Create URL Request
        guard let url = URL(string: "https://petaidcloud.onrender.com/diagnose") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send Request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received."
                }
                return
            }

            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let result = response["diagnosis"] as? String {
                DispatchQueue.main.async {
                    diagnosis = result
                    errorMessage = nil // clear any previous error
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Could not decode response."
                }
            }
        }.resume()
    }
    func resizeImage(image: UIImage, targetWidth: CGFloat) -> UIImage {
        let size = image.size
        let widthRatio = targetWidth / size.width
        let newSize = CGSize(width: targetWidth, height: size.height * widthRatio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }

}


#Preview {
    IllnessView()
}
