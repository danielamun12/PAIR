//
//  SortingView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/17/24.
//

import SwiftUI
import Vision

enum SortingStage: Equatable {
    case loading
    case fullReceipt
    case items
    case categories
}

struct SortingView: View {
    @State var businessItmes: [[String]] = []
    @State var personalItems: [String] = []
    @State var image: UIImage? = nil
    
    @State private var receiptObservations: [String] = []
    
    var body: some View {
        ZStack {
            appBackground()
            if image == nil {
                CameraView(camera: CameraModel(), image: $image, stringResults: $receiptObservations)
            } else {
                ReceiptSortingView(image: $image, receiptObservations: $receiptObservations)
            }
        }
    }
}

struct ReceiptSortingView: View {
    @Binding var image: UIImage?
    @Binding var receiptObservations: [String]
    
    @State var storeName: String = ""
    @State var date: String = ""
    @State var subtotal: Double = 0.0
    @State var tax: Double = 0.0
    @State var total: Double = 0.0
    @State var allItems: [String: Double] = [:]
    
    //SORTING
    @State var sortingStage: SortingStage = .loading
    @State var unsortedItems: [String: Double] = [:]
    @State var selected: [String: Double] = [:]
    @State var business: [String: Double] = [:]
    @State var personal: [String: Double] = [:]
    @State var categoriesIems: [String: String] = [:]
    
    var body: some View {
        ZStack {
            appBackground()
            switch sortingStage {
            case .loading: EmptyView()
            case .fullReceipt:
                FullReceiptSortingView(storeName: storeName, date: date, subtotal: subtotal, tax: tax, total: total, allItems: allItems, sortingStage: $sortingStage, unsortedItems: $unsortedItems, selected: $selected, business: $business, personal: $personal, categoriesItems: $categoriesIems)
            case .items:
                ItemSortingView(storeName: storeName, date: date, subtotal: subtotal, tax: tax, total: total, sortingStage: $sortingStage, unsortedItems: $unsortedItems, selected: $selected, business: $business, personal: $personal, categoriesItems: $categoriesIems)
            case .categories:
                CategorySortingView(storeName: storeName, date: date, subtotal: subtotal, tax: tax, total: total, sortingStage: $sortingStage, unsortedItems: $unsortedItems, selected: $selected, business: $business, personal: $personal, categoriesItems: $categoriesIems)
            }
        }.onAppear {
            (storeName, date, allItems, subtotal, tax, total) = extractReceiptInfo(receipt: receiptObservations)
            unsortedItems = allItems
            sortingStage = .fullReceipt
        }
    }
}

struct FullReceiptSortingView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var storeName: String
    @State var date: String
    @State var subtotal: Double
    @State var tax: Double
    @State var total: Double
    @State var allItems: [String: Double]
    
    //SORTING
    @Binding var sortingStage: SortingStage
    @Binding var unsortedItems: [String: Double]
    @Binding var selected: [String: Double]
    @Binding var business: [String: Double]
    @Binding var personal: [String: Double]
    @Binding var categoriesItems: [String: String]
    
    var body: some View {
        ZStack {
            VStack (spacing: 15){
                VStack (spacing: 0){
                    HStack {
                        Spacer()
                        Button(action:  {presentationMode.wrappedValue.dismiss()}) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(.black)
                        }
                    }.padding(.top, 20)
                    // HEADER (NAME, DATE, TOTAL)
                    HStack {
                        VStack (alignment: .leading, spacing: 25) {
                            VStack (alignment: .leading, spacing: 10) {
                                Text(storeName.prefix(1).capitalized + storeName.dropFirst())
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundStyle(.black)
                                VStack (alignment: .leading, spacing: 5){
                                    Text(date)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.black.opacity(0.7))
                                    Text("Paid by Visa xxxx xxxx xxxx 5612")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.black.opacity(0.7))
                                }
                            }
                            Text("$"+String(format: "%.2f", total))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(greenGradient)
                        }.padding(.bottom, 20)
                        Spacer()
                    }
                }.padding(.horizontal, 20)
                
                HStack (spacing: 50){
                    Spacer()
                    Text("QTY")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(.black.opacity(0.75))
                    Text("PRICE")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(.black.opacity(0.75))
                }.padding(.horizontal, 40)
                
                //ITEMS
                ScrollView (showsIndicators: false){
                    VStack (spacing: 10) {
                        ForEach(allItems.sorted(by: >), id: \.key) {name, price in
                            VStack (spacing: 0){
                                IndividualItem(name: name, price: price, sortingStage: $sortingStage, categoriesItems: $categoriesItems, selected: $selected, items: $unsortedItems)
                                if !(allItems.sorted(by: >).last?.key == name) {
                                    Divider()
                                        .foregroundStyle(Color(#colorLiteral(red: 0.727246105670929, green: 0.727246105670929, blue: 0.727246105670929, alpha: 1)))
                                        .padding(.horizontal, 25)
                                }
                            }
                        }
                    }.padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color(#colorLiteral(red: 0.727246105670929, green: 0.727246105670929, blue: 0.727246105670929, alpha: 1)), lineWidth: 1)
                                .padding(.horizontal, 15)
                        )
                    Rectangle().foregroundStyle(.clear).frame(height: 200)
                }.clipped()
            }
            // BOTTOM SHEET
            VStack {
                Spacer()
                VStack (spacing: 20){
                    Text("SORT RECEIPT AS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .tracking(0.84)
                    HStack (spacing: 15){
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(#colorLiteral(red: 0.307534396648407, green: 0.7093750238418579, blue: 0.34406521916389465, alpha: 1)))
                                .frame(height: 45)
                            Text("PERSONAL")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .tracking(0.48)
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(#colorLiteral(red: 0.307534396648407, green: 0.7093750238418579, blue: 0.34406521916389465, alpha: 1)))
                                .frame(height: 45)
                            Text("BUSINESS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .tracking(0.48)
                        }
                    }
                    Button(action: {sortingStage = .items}) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(#colorLiteral(red: 0.239215686917305, green: 0.46666666865348816, blue: 0.26274511218070984, alpha: 1)))
                                .frame(height: 45)
                            Text("MIXED")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .tracking(0.48)
                        }
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 25)
                .padding(.horizontal, 30)
                .background(RoundedRectangle(cornerRadius: 15)
                    .fill(greenGradient))
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct ItemSortingView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var storeName: String
    @State var date: String
    @State var subtotal: Double
    @State var tax: Double
    @State var total: Double
    @Binding var sortingStage: SortingStage
    
    //SORTING
    @Binding var unsortedItems: [String: Double]
    @Binding var selected: [String: Double]
    @Binding var business: [String: Double]
    @Binding var personal: [String: Double]
    @Binding var categoriesItems: [String: String]
    
    @State var incompleteSortingAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack (spacing: 15){
                // HEADER (NAME, TOTAL)
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        HStack {
                            Text(storeName.prefix(1).capitalized + storeName.dropFirst())
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.black)
                            Spacer()
                            Button(action:  {presentationMode.wrappedValue.dismiss()}) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundStyle(.black)
                            }
                        }
                        
                        Text("$"+String(format: "%.2f", total))
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }.padding(.horizontal, 30)
                    .padding(.top, 20)
                
                HStack (spacing: 50){
                    Spacer()
                    Text("QTY")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(.black.opacity(0.75))
                    Text("PRICE")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(.black.opacity(0.75))
                }.padding(.horizontal, 40)
                
                //ITEMS
                ScrollView (showsIndicators: false){
                    VStack (spacing: 10){
                        VStack (spacing: 0){
                            ForEach(unsortedItems.sorted(by: >), id: \.key) { name, price in
                                VStack (spacing: 0){
                                    IndividualItem(name: name, price: price, sortingStage: $sortingStage, categoriesItems: $categoriesItems, selected: $selected, items: $unsortedItems)
                                    Divider()
                                        .foregroundStyle(Color(#colorLiteral(red: 0.727246105670929, green: 0.727246105670929, blue: 0.727246105670929, alpha: 1)))
                                        .padding(.horizontal, 25)
                                }
                            }
                        }.background(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color(#colorLiteral(red: 0.727246105670929, green: 0.727246105670929, blue: 0.727246105670929, alpha: 1)), lineWidth: 1)
                                .padding(.horizontal, 15)
                        )
                        if !business.isEmpty {
                            GroupItems(groupName: "Business", sortingStage: $sortingStage, items: $business, selected: $selected, categoriesItems: $categoriesItems)
                        }
                        if !personal.isEmpty {
                            GroupItems(groupName: "Personal", sortingStage: $sortingStage, items: $personal, selected: $selected, categoriesItems: $categoriesItems)
                        }
                        Rectangle().foregroundStyle(.clear).frame(height: 125)
                    }
                }.clipped()
            }
            
            // BOTTOM SHEET
            VStack {
                Spacer()
                VStack (spacing: 20){
                    HStack {
                        Button(action: {sortingStage = .fullReceipt}) {
                            ZStack {
                                Circle()
                                    .foregroundStyle(Color(#colorLiteral(red: 0.239215686917305, green: 0.46666666865348816, blue: 0.26274511218070984, alpha: 1)))
                                    .frame(width: 23)
                                Image(systemName: "arrow.left")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14))
                            }
                        }
                        Spacer()
                        Text("SORT SELECTED AS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(0.84)
                        Spacer()
                        Button(action: {
                            if unsortedItems.keys.isEmpty {
                                sortingStage = .categories
                            } else {
                                incompleteSortingAlert = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .foregroundStyle(Color(#colorLiteral(red: 0.239215686917305, green: 0.46666666865348816, blue: 0.26274511218070984, alpha: 1)))
                                    .frame(width: 23)
                                Image(systemName: "arrow.right")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    HStack (spacing: 15){
                        Button(action: {
                            for key in selected.keys {
                                business.removeValue(forKey: key)
                                unsortedItems.removeValue(forKey: key)
                            }
                            personal.merge(selected) { (_, new) in new }
                            selected = [:]
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(#colorLiteral(red: 0.307534396648407, green: 0.7093750238418579, blue: 0.34406521916389465, alpha: 1)))
                                    .frame(height: 45)
                                Text("PERSONAL")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .tracking(0.48)
                            }
                        }
                        
                        Button(action: {
                            for key in selected.keys {
                                personal.removeValue(forKey: key)
                                unsortedItems.removeValue(forKey: key)
                            }
                            business.merge(selected) { (_, new) in new }
                            selected = [:]
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(#colorLiteral(red: 0.307534396648407, green: 0.7093750238418579, blue: 0.34406521916389465, alpha: 1)))
                                    .frame(height: 45)
                                Text("BUSINESS")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .tracking(0.48)
                            }
                        }
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 25)
                .padding(.horizontal, 30)
                .background(RoundedRectangle(cornerRadius: 15)
                    .fill(greenGradient))
            }
            .alert("Please make sure to sort all items before moving on.", isPresented: $incompleteSortingAlert) {
                Button("OK", role: .cancel) { }
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct CategorySortingView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var storeName: String
    @State var date: String
    @State var subtotal: Double
    @State var tax: Double
    @State var total: Double
    @Binding var sortingStage: SortingStage
    
    //SORTING
    @Binding var unsortedItems: [String: Double]
    @Binding var selected: [String: Double]
    @Binding var business: [String: Double]
    @Binding var personal: [String: Double]
    @Binding var categoriesItems: [String: String]
    
    @State var incompleteSortingAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack (spacing: 15){
                // HEADER (NAME, TOTAL)
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        HStack {
                            Text(storeName.prefix(1).capitalized + storeName.dropFirst())
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.black)
                            Spacer()
                            Button(action:  {presentationMode.wrappedValue.dismiss()}) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundStyle(.black)
                            }
                        }
                        
                        Text("$"+String(format: "%.2f", total))
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }.padding(.horizontal, 30)
                    .padding(.top, 20)
                
                HStack (spacing: 20){
                    Spacer()
                    Text("QTY")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(.black.opacity(0.75))
                    Text("PRICE")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(.black.opacity(0.75))
                    Text("CAT")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(.black.opacity(0.75))
                }.padding(.horizontal, 40)
                
                //ITEMS
                ScrollView (showsIndicators: false){
                    VStack (spacing: 10){
                        if !business.isEmpty {
                            GroupItems(groupName: "Business", sortingStage: $sortingStage, items: $business, selected: $selected, categoriesItems: $categoriesItems, openList: true)
                        }
                        Rectangle().foregroundStyle(.clear).frame(height: 300)
                    }
                }.clipped()
            }
            // BOTTOM SHEET
            VStack {
                Spacer()
                VStack (spacing: 20){
                    HStack {
                        Button(action: {sortingStage = .items}) {
                            ZStack {
                                Circle()
                                    .foregroundStyle(Color(#colorLiteral(red: 0.239215686917305, green: 0.46666666865348816, blue: 0.26274511218070984, alpha: 1)))
                                    .frame(width: 23)
                                Image(systemName: "arrow.left")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14))
                            }
                        }
                        Spacer()
                        Text("CATEGORIZE SELECTED AS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(0.84)
                        Spacer()
                        Button(action: {
                            var allCategorized = true
                            for key in business.keys {
                                if let category = categoriesItems[key], !category.isEmpty {
                                    continue
                                } else {
                                    allCategorized = false
                                    incompleteSortingAlert = true
                                    break
                                }
                            }
                            if allCategorized {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .foregroundStyle(Color(#colorLiteral(red: 0.239215686917305, green: 0.46666666865348816, blue: 0.26274511218070984, alpha: 1)))
                                    .frame(width: 23)
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    VStack (spacing: 15) {
                        HStack (spacing: 15){
                            categoryButton(categoryName: "TRAVEL & TRANSPORT", iconName: "car", selected: $selected, categoriesItems: $categoriesItems)
                            categoryButton(categoryName: "UTILITIES", iconName: "lightbulb", selected: $selected, categoriesItems: $categoriesItems)
                            categoryButton(categoryName: "EQUIPMENT & SUPPLIES", iconName: "wrench.and.screwdriver", selected: $selected, categoriesItems: $categoriesItems)
                        }
                        HStack (spacing: 15){
                            categoryButton(categoryName: "SALARIES & WAGES", iconName: "banknote", selected: $selected, categoriesItems: $categoriesItems)
                            categoryButton(categoryName: "SOFTWARE", iconName: "tv", selected: $selected, categoriesItems: $categoriesItems)
                            categoryButton(categoryName: "OTHER", iconName: "", selected: $selected, categoriesItems: $categoriesItems)
                        }
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 25)
                .padding(.horizontal, 30)
                .background(RoundedRectangle(cornerRadius: 15)
                    .fill(greenGradient))
            }
        }.alert("Please make sure to categorize all items.", isPresented: $incompleteSortingAlert) {
            Button("OK", role: .cancel) { }
        }
        .navigationBarBackButtonHidden(true)
    }
}
