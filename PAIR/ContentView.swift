//
//  ContentView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        
        NavigationView {
            ZStack {
                appBackground()
                TabView (selection: $selectedTab) {
                    Home()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(1)
                    ReceiptListView()
                        .tabItem {
                            Label("Receipts", systemImage: "scroll.fill")
                        }
                        .tag(2)
                    Settings()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(3)
                }
            }
        }
    }
}
