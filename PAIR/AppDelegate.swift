//
//  AppDelegate.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/17/24.
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        configureNavigationBarAppearance()
        return true
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        let image = UIImage(systemName: "chevron.backward")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let backItemAppearance = UIBarButtonItemAppearance()
        
        appearance.configureWithTransparentBackground()
        appearance.setBackIndicatorImage(image, transitionMaskImage: image)
        appearance.backButtonAppearance = backItemAppearance
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "TextColor") ?? .white]
        
        backItemAppearance.normal.titleTextAttributes = [.foregroundColor: Color.black]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
    }
}

struct appBackground: View{
    var body: some View{
        ZStack{
            Color.white.ignoresSafeArea()
        }.ignoresSafeArea()
    }
}

let screenSize = UIScreen.main.bounds.size

extension UINavigationController {
    // Remove navigation "back" text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
    
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

let greenGradient = LinearGradient(
    gradient: Gradient(stops: [
        .init(color: Color(#colorLiteral(red: 0.3849477469921112, green: 0.8138183355331421, blue: 0.42224085330963135, alpha: 1)), location: 0),
        .init(color: Color(#colorLiteral(red: 0.5774057507514954, green: 0.8213704228401184, blue: 0.5986198782920837, alpha: 1)), location: 1)]),
    startPoint: UnitPoint(x: 0.011235987979254458, y: 0.02209937045779875),
    endPoint: UnitPoint(x: 0.9803370915035547, y: 0.9640884194913579))
