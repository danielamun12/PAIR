//
//  CameraView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/21/24.
//

import SwiftUI
import AVFoundation
import Vision

struct CameraView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var camera: CameraModel
    @Binding var image: UIImage?
    
    @State var postingPicture = false
    @State var picSaved = false
    @State var tap = false
    @State var tapLocation: CGPoint = CGPointMake(0.0, 0.0)
    @State var scaler = 0.8
    
    //SCANNING
    @State var observations: [VNRecognizedTextObservation] = []
    @Binding var stringResults: [String]
    @State var updatedReceipt: UIImage? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if camera.picTaken {
                ZStack{
                    Image(uiImage: visualization(camera.image!, observations: observations))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenSize.width, height: screenSize.height)
                }
                .frame(width: screenSize.width)
                .ignoresSafeArea()
            } else {
                CameraPreview(camera: camera)
                    .frame(width: screenSize.width)
                    .cornerRadius(20)
                    .ignoresSafeArea()
                    .onTapGesture(count: 1, coordinateSpace: .local) { location in
                        tapLocation = location
                        let focusPoint = CGPointMake(location.x/screenSize.width, location.y/screenSize.height)
                        camera.setFocus(location: focusPoint)
                        tap = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01){
                            scaler = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                            tap = false
                            scaler = 0.5
                        }
                    }
                if tap {
                    Circle()
                        .scale(scaler)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 45)
                        .animation(.linear, value: scaler)
                        .position(tapLocation)
                }
                
            }
            
            if !camera.picTaken {
                VStack{
                    HStack {
                        Button(action: {presentationMode.wrappedValue.dismiss()}){
                            Image(systemName: "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: {
                            if (camera.flashMode == .off) {
                                camera.flashMode = .on
                            } else {
                                camera.flashMode = .off
                            }}) {
                                Image(systemName: (camera.flashMode == .on) ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 25))
                                    .foregroundColor((camera.flashMode == .on) ? .yellow : .white)
                            }
                    }.padding(.horizontal, 20)
                        .padding(.top, 15)
                    Spacer()
                    ZStack{
                        HStack{
                            Button(action: camera.takePic) {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 69, height: 69)
                                    Circle()
                                        .fill(.white).strokeBorder(.black, lineWidth: 2)
                                        .frame(width: 62, height: 62)
                                }
                            }
                        }
                    }
                }.onAppear{self.postingPicture = false}
                    .padding(.bottom, 40)
            } else {
                // Retake Button
                VStack{
                    HStack{
                        Button(action: {
                            camera.reTake()
                        }){
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    Spacer()
                }.padding(.leading, 20)
                    .padding(.top, 50)
                
                HStack{
                    Spacer()
                    VStack(spacing: 35){
                        Spacer()
                        Button(action: {
                            camera.savePic()
                            picSaved = true
                        })
                        {Image(systemName: picSaved ? "checkmark.circle.fill" : "arrow.down.to.line")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 35)
                                .foregroundColor(.white)
                        }.disabled(picSaved)
                        
                        Button (action: {
                            self.postingPicture = true
                            image = camera.image!
                        }) {
                            if postingPicture {
                                ProgressView()
                                    .scaleEffect(2)
                                    .tint(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(45))
                            }
                        }.frame(width: 30, height: 30)
                            .disabled(postingPicture)
                            .padding(.trailing, 10)
                            .padding(.bottom, 50)
                    }
                }.padding(.horizontal, 15)
            }
        }.onAppear(perform: {
            if !camera.cameraSetUp {
                camera.checkPermissions()
            }
            if (camera.camera.deviceType == .builtInUltraWideCamera) {
                camera.setZoom(zoom: 2.0)
            } else {
                camera.setZoom(zoom: 1.0)
            }
        })
        .onChange(of: camera.picTaken) {
            if camera.picTaken {
                processCapturedImage()
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func processCapturedImage() {
        guard let capturedImage = camera.image else { return }
        observations = processImage(capturedImage) ?? []
        stringResults = observationsToString(observations: observations)
    }
}

class CameraModel: NSObject,ObservableObject,AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var discoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
    @Published var camera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)!
    @Published var alert = false
    @Published var input: AVCaptureDeviceInput!
    @Published var output: AVCapturePhotoOutput!
    @Published var preview = AVCaptureVideoPreviewLayer()
    @Published var picTaken = false
    @Published var image: UIImage?
    @Published var cameraSetUp = false
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){ (status) in
                if status {
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp() {
        let session = AVCaptureMultiCamSession()
        do {
            camera = discoverSession.devices[0]
            input = try AVCaptureDeviceInput(device: camera)
            output = AVCapturePhotoOutput()
            session.beginConfiguration()
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            preview.videoGravity = .resizeAspectFill
            preview.session = session
            preview.isHidden = false
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            
            self.session = session
            self.cameraSetUp = true
            
        } catch {
            print("Error setting up cameras: \(error)")
        }
    }
    
    func getSettings() -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        
        if self.camera.hasFlash {
            settings.flashMode = self.flashMode
        }
        settings.photoQualityPrioritization = output.maxPhotoQualityPrioritization
        
        return settings
    }
    
    func takePic() {
        self.output.capturePhoto(with: self.getSettings(), delegate: self)
    }
    
    func setFocus(location: CGPoint) {
        do {
            let device = input.device
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = location
                device.focusMode = .continuousAutoFocus
            }
            device.unlockForConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func reTake(){
        self.picTaken = false
        self.image = nil
    }
    
    @MainActor func photoOutput (_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil{
            print(error?.localizedDescription ?? "")
            return
        }
        
        guard let cgImage = photo.cgImageRepresentation() else {return}
        let ogImage = UIImage(cgImage: photo.cgImageRepresentation()!)
        self.image = ogImage.rotate(radians: .pi/2) 
        self.picTaken = true
    }
    
    func setZoom(zoom: CGFloat){
        do {
            let device = input.device
            try device.lockForConfiguration()
            device.videoZoomFactor = zoom
            device.unlockForConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func savePic(){
        UIImageWriteToSavedPhotosAlbum(self.image ?? UIImage(), nil, nil, nil)
    }
    
}

struct CameraPreview: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIViewController
    @ObservedObject var camera : CameraModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        viewController.view.layer.addSublayer(camera.preview)
        camera.preview.frame =  CGRect(x: viewController.view.bounds.minX,
                                               y: viewController.view.bounds.minY,
                                               width: viewController.view.bounds.width,
                                               height: viewController.view.bounds.height)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
