//
//  CameraView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/21/24.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject var camera: CameraModel
    @State var postingPicture = false
    @State var picSaved = false
    
    @State var tap = false
    @State var tapLocation: CGPoint = CGPointMake(0.0, 0.0)
    @State var scaler = 0.8
    
    var body: some View {
        NavigationView{
                ZStack {
                    Color.black.ignoresSafeArea()
                    if camera.picTaken {
                        ZStack{
                            Image(uiImage: camera.image!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: screenSize.height - 70)
                        }
                        .frame(width: screenSize.width)
                        .cornerRadius(20)
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
                            }.padding(.trailing, 20)
                                .padding(.top, 15)
                            Spacer()
                            ZStack{
                                HStack{
                                    Button(action: camera.takePic,
                                           label: {Circle()
                                            .stroke(Color.white, lineWidth: 8)
                                            .frame(width: 75, height: 75)
                                    })
                                }
                            }
                        }.onAppear{self.postingPicture = false}
                            .padding(.bottom, 40)
                    } else {
                        // X Button
                        VStack{
                            HStack{
                                Button(action: {camera.reTake()}){
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 20)
                                            .foregroundColor(.white)
                                    }
                                Spacer()
                            }
                            Spacer()
                        }.padding(.leading, 20)
                            .padding(.top, 35)
                        
                    
                        // ACTIONS
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
                                        .frame(height: 30)
                                        .foregroundColor(.white)
                                }.disabled(picSaved)
                                
                                Button (action: {
                                    self.postingPicture = true
                                    camera.reTake()
                                }) {
                                    if postingPicture {
                                        ProgressView()
                                            .scaleEffect(2)
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white)
                                            .rotationEffect(.degrees(45))
                                    }
                                }.frame(width: 30, height: 30)
                                    .disabled(postingPicture)
                                    .padding(.trailing, 10)
                            }
                        }.padding(.horizontal, 15)
                            .padding(.bottom, 55)
                            .ignoresSafeArea(.keyboard)
                    }
            } .onAppear(perform: {
                print("camera onAppear")
                print("camera.cameraSetUp", camera.cameraSetUp)
                if !camera.cameraSetUp {
                    camera.checkPermissions()
                }
            })
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
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
                print("added input")
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
                print("added output")
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
        print("take pic called")
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
        print("exit")
        self.picTaken = false
        self.image = nil
    }
    
    @MainActor func photoOutput (_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("in photo output")
        if error != nil{
            print(error?.localizedDescription ?? "")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {return}
        self.image = UIImage(data: imageData)!
        self.picTaken = true
    }
    
    func savePic(){
        UIImageWriteToSavedPhotosAlbum(self.image ?? UIImage(), nil, nil, nil)
        print("saved to camera roll")
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
                                               height: viewController.view.bounds.height - 70)
                
                print("viewController.view.bounds", viewController.view.bounds)
                print("camera.preview.frame", camera.preview.frame)
                print(screenSize, "screenSize")
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
