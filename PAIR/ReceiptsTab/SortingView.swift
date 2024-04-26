//
//  SortingView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/17/24.
//

import SwiftUI
import Vision

struct SortingView: View {
    @Binding var receipt: String?
    @State var businessItmes: [[String]] = []
    @State var personalItems: [String] = []
    
    var body: some View {
        ZStack {
            appBackground()
            Text("SORTING")
        }
    }
}

