//
//  PAIRApp.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/10/24.
//

import SwiftUI

@main
struct PAIRApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
