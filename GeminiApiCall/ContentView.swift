//
//  ContentView.swift
//  GeminiApiCall
//
//  Created by Onur Uğur on 7.03.2024.
//

import SwiftUI
import GoogleGenerativeAI
import AVFoundation
import Photos

// Ana SwiftUI görünümü
struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var apiResponse: String?
    @State private var isActionSheetPresented = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
            }
            
            Button("Fotoğraf Seç") {
                isActionSheetPresented = true
            }
            .actionSheet(isPresented: $isActionSheetPresented) {
                ActionSheet(title: Text("Fotoğraf Yükle"), message: Text("Bir kaynak seçin"), buttons: [
                    .default(Text("Kamerayı Aç")) {
                        self.sourceType = .camera
                        self.isImagePickerPresented = true
                    },
                    .default(Text("Galeriyi Aç")) {
                        self.sourceType = .photoLibrary
                        self.isImagePickerPresented = true
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }
            
            Button("Fotoğrafı Gönder") {
                if let selectedImage = selectedImage {
                    sendImageToAPI(image: selectedImage)
                }
            }
            
            //MARK: - API RESPONSE
            if let apiResponse = apiResponse {
                ScrollView{
                    Text(apiResponse)
                        .padding()
                }
            }
        }
    }
    
    func sendImageToAPI(image: UIImage) {
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 300, height: 300))
        
        // API anahtarınızı burada sağlayın
        //MARK: - API KEY ENTER
        let apiKey = "API KEY" // Gerçek API anahtarınızı buraya girin
        let model = GenerativeModel(name: "gemini-pro-vision", apiKey: apiKey)
        
        //MARK: - PROMPT
        
        let prompt = "What is the technical name and description of the disease this plant is suffering from? Additionally, can you provide a solution for this disease?"
        
        Task {
            do {
                let response = try await model.generateContent(prompt, resizedImage)
                if let text = response.text {
                    DispatchQueue.main.async {
                        self.apiResponse = text
                    }
                }
            } catch {
                print("Error generating content: \(error)")
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}

// SwiftUI'nin gerektirdiği diğer destekleyici yapılar (örneğin ImagePicker) burada tanımlanmalıdır ancak bu örnekte belirtilmemiştir.
// Tam bir uygulama için, eksik yapıların (örneğin, kullanıcıdan fotoğraf seçimine izin veren ImagePicker gibi) tanımlarını eklemeniz gerekecektir.
