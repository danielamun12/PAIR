//
//  ReceiptListView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/24/24.
//

import SwiftUI

struct ReceiptListView: View {
    @State var receipt: String? = nil
    var body: some View {
        ZStack {
            appBackground()
            NavigationLink(destination: SortingView(receipt: $receipt)){
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
