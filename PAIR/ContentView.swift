//
//  ContentView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/10/24.
//

import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var pageToNavigationTo : String?
}


struct Dest : View {
    var message : String
    var body: some View {
        Text("\(message)")
    }
}


struct ContentView: View {
    @ObservedObject var appState = AppState.shared
    @State var navigate = false
    @State private var selectedTab = 1
    
    var pushNavigationBinding : Binding<Bool> {
        .init { () -> Bool in
            appState.pageToNavigationTo != nil
        } set: { (newValue) in
            if !newValue { appState.pageToNavigationTo = nil }
        }
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                appBackground()
                TabView (selection: $selectedTab) {
                    ReceiptListView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(1)
                    ReceiptListView()
                        .tabItem {
                            Label("Receipts", systemImage: "scroll.fill")
                        }
                        .overlay(NavigationLink(destination: SortingView(receipt: $appState.pageToNavigationTo),
                                                isActive: pushNavigationBinding) {
                            EmptyView()
                        })
                        .tag(2)
                    ReceiptListView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(3)
                }
            }
        }
    }
}
