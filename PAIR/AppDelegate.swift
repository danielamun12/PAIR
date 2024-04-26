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
        configureTabBarAppearance()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
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
    
    private func configureTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "BottomBar")
        tabBarAppearance.shadowColor = .clear
        
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "PrimaryButton")]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "PrimaryButton")
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let receiptIDString = userInfo["receiptID"] as? String {
            AppState.shared.pageToNavigationTo = receiptIDString
        }
        completionHandler()
    }
}

struct appBackground: View{
    var body: some View{
        ZStack{
            Color("BackgroundOffwhite").ignoresSafeArea()
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

func sendReceiptNotification() {
    let receiptID = UUID() // Identify the specific receipt
    let content = UNMutableNotificationContent()
    content.title = "New Receipt Notification"
    content.body = "Tap to view receipt"
    content.userInfo = ["receiptID": receiptID]
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: "receiptNotification", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
}
