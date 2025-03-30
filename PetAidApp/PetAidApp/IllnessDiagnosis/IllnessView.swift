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
    @FocusState private var isFocused: Bool
    
    @State private var diagnosis: String? = nil // response
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    let pet: Pet
//Add take live photo
    
    var body: some View {

            ZStack {
                Color.teal.ignoresSafeArea()
                ScrollView {
                LazyVStack(spacing: 20) {
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
                        .focused($isFocused)
                        

                    
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
                        Text(LocalizedStringKey(diagnosis))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green.opacity(0.5))
                            .cornerRadius(10)
                        
                    }
                    
                    Spacer()
                }
                .padding()
            }
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
            }.toolbar {
                ToolbarItem() {
                    Button("Done") {
                        isFocused = false
                    }
                }
            }

    }
    
    // MARK: Networking
    func sendToBackend() {
        guard !description.isEmpty else { return }
        isLoading = true
        
        // Create JSON Payload
        var payload: [String: Any] = [
            "description": description,
            "lastVetVisit": pet.lastVetVisit,
            "pastIllnesses": pet.pastIllnesses,
            "name": pet.name,
            "age": pet.age,
            "species": pet.species,
            "breed": pet.breed
        ]

        
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
        guard let url = URL(string: "https://petaidcloud.onrender.com/post-data") else { return }

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

            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    // Build a nice formatted result
                    var result = ""
                    result += "🩺 **Possible Issue:** \(response["possible_issue"] as? String ?? "Unknown")\n\n"
                    result += "📊 **Likelihood:** \(response["likelihood"] as? String ?? "Unknown")\n\n"
                    result += "⚠️ **Severity:** \(response["severity"] as? String ?? "Unknown")\n\n"
                    result += "💡 **Explanation:**\n\(response["explanation"] as? String ?? "No explanation provided.")\n\n"
                    result += "✅ **Recommendation:**\n\(response["recommendation"] as? String ?? "No recommendation provided.")"

                    // Display it
                    diagnosis = result
                    errorMessage = nil
                    
        
                }
            } else {

                DispatchQueue.main.async {
                    if let dataString = String(data: data, encoding: .utf8) {
                        errorMessage = "Unexpected response: \(dataString)"
                    } else {
                        errorMessage = "Could not decode response."
                    }

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
    IllnessView(
        pet: Pet(
            name: "Buddy",
            age: "3",
            species: "Dog",
            breed: "Golden Retriever",
            imageFilename: "",
            lastVetVisit: "01/01/2025",
            pastIllnesses: "None"
        )
    )
}
