//
//  AppDelegate.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/17/24.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        configureNavigationBarAppearance()
        return true
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        let image = UIImage(systemName: "chevron.backward")?.withTintColor(UIColor(Color("Green")), renderingMode: .alwaysOriginal)
        let backItemAppearance = UIBarButtonItemAppearance()
        
        appearance.configureWithTransparentBackground()
        appearance.setBackIndicatorImage(image, transitionMaskImage: image)
        appearance.backButtonAppearance = backItemAppearance
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "TextColor") ?? .white]
        
        backItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color("Green"))]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
    }
}

struct appBackground: View{
    var body: some View{
        ZStack{
            Color("Green").ignoresSafeArea()
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
