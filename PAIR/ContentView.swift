//
//  ContentView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/10/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            ZStack {
                appBackground()
                NavigationLink(destination: SortingView()){
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("PrimaryButton"))
                            .frame(height: 65)
                        Text("ADD RECEIPT")
                    }
                }.padding()
            }
        }
    }
}
