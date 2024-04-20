//
//  SortingView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/17/24.
//

import SwiftUI

struct SortingView: View {
    @State var businessItmes: [[String]] = []
    @State var personalItems: [String] = []
    
    var body: some View {
        ZStack {
            appBackground()
        }
    }
}

#Preview {
    SortingView()
}
