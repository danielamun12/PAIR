//
//  ScanningView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/21/24.
//

import SwiftUI
import Vision
import UIKit

struct ScanningView: View {
    
    @State private var observations: [VNRecognizedTextObservation] = []
    @State private var stringResults: [String] = []
    @State private var capturedImage: UIImage? = nil
    @State var updatedReceipt: UIImage? = nil
    @State private var showingImagePicker = false
    
    var body: some View {
        ZStack {
            appBackground()
            
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width)
            } else {
                Text("No Image Captured")
                    .foregroundColor(.white)
            }
            
            VStack {
                Spacer()
                
                Button("Capture Photo") {
                    self.showingImagePicker = true
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: processCapturedImage) {
            ImagePicker(image: self.$capturedImage).ignoresSafeArea()
        }
    }
    
    func processCapturedImage() {
        guard let capturedImage = capturedImage else { return }
        
        observations = processImage(capturedImage) ?? []
        stringResults = observationsToString(observations: observations)
        print(stringResults)
        print(extractReceiptInfo(receipt: stringResults))
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
