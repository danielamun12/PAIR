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
    case items
    case categories
    case final
}

enum ViewCase: Equatable {
    case all
    case business
    case personal
    
    var stringValue: String {
        switch self {
        case .all:
            return "View All"
        case .business:
            return "Business"
        case .personal:
            return "Personal"
        }
    }
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
            case .items:
                ItemSortingView(storeName: storeName, date: date, subtotal: subtotal, tax: tax, total: total, sortingStage: $sortingStage, unsortedItems: $unsortedItems, selected: $selected, business: $business, personal: $personal, categoriesItems: $categoriesIems)
            case .categories:
                CategorySortingView(storeName: storeName, date: date, subtotal: subtotal, tax: tax, total: total, sortingStage: $sortingStage, unsortedItems: $unsortedItems, selected: $selected, business: $business, personal: $personal, categoriesItems: $categoriesIems)
            case .final:
                ConfirmationSortingView(storeName: storeName, date: date, subtotal: subtotal, tax: tax, total: total, sortingStage: $sortingStage, unsortedItems: $unsortedItems, selected: $selected, business: $business, personal: $personal, categoriesItems: $categoriesIems)
            }
        }.onAppear {
            (storeName, date, allItems, subtotal, tax, total) = extractReceiptInfo(receipt: receiptObservations)
            unsortedItems = allItems
            sortingStage = .items
        }
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
    
    var body: some View {
        ZStack {
            VStack (spacing: 20){
                // HEADER (NAME, TOTAL)
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        HStack {
                            Text(storeName)
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
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color("SecondaryText"))
                        Text(date)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color("SecondaryText"))
                    }
                    Spacer()
                }.padding(.horizontal, 30)
                    .padding(.top, 20)
                
                Text(unsortedItems.keys.isEmpty ? "CLICK THE CHECK TO CONTINUE" : "SELECT ITEMS YOU WANT TO SORT")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.black)
                
                if !unsortedItems.keys.isEmpty {
                    HStack {
                        HStack (spacing: 25){
                            Button (action: {selected = unsortedItems}) {
                                notCheckedBox()
                            }
                            Text("ITEM NAME")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(0.96)
                                .foregroundStyle(Color("SecondaryText"))
                        }.padding(.leading, 25)
                        Spacer()
                        HStack (spacing: 60){
                            Text("QTY")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(0.96)
                                .foregroundStyle(Color("SecondaryText"))
                            Text("PRICE")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(0.96)
                                .foregroundStyle(Color("SecondaryText"))
                        }.padding(.trailing, 40)
                    }
                }
                
                //ITEMS
                ScrollView (showsIndicators: false){
                    VStack (spacing: 10){
                        VStack (spacing: 0){
                            ForEach(unsortedItems.sorted(by: >), id: \.key) { name, price in
                                VStack (spacing: 0){
                                    IndividualItem(name: name, price: price, sortingStage: $sortingStage, categoriesItems: $categoriesItems, selected: $selected, items: $unsortedItems)
                                    Divider()
                                        .foregroundStyle(Color("SecondaryText"))
                                        .padding(.horizontal, 25)
                                }
                            }
                        }.background(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color("SecondaryText"), lineWidth: 1)
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
                    ZStack {
                        Text("Sort selected as")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(0.72)
                        if unsortedItems.keys.isEmpty {
                            HStack {
                                Spacer()
                                Button(action: {
                                    sortingStage = .categories
                                }) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color("PrimaryGreen"))
                                        .font(.system(size: 16, weight: .bold))
                                }.padding(.horizontal, 20)
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
                                    .foregroundStyle(.white)
                                    .frame(height: 45)
                                Text("PERSONAL")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color("PrimaryGreen"))
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
                                    .foregroundStyle(greenGradient)
                                    .frame(height: 45)
                                Text("CAKES BY T")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .tracking(0.48)
                            }
                        }
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 25)
                .padding(.horizontal, 15)
                .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(.black).shadow(color: .black, radius: 4))
            }.padding(.horizontal, 20)
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
    
    var body: some View {
        ZStack {
            VStack (spacing: 20){
                // HEADER (NAME, TOTAL)
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        HStack {
                            Text(storeName)
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
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color("SecondaryText"))
                        Text(date)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color("SecondaryText"))
                    }
                    Spacer()
                }.padding(.horizontal, 30)
                    .padding(.top, 20)
                
                HStack {
                    HStack (spacing: 25){
                        Button (action: {selected = business}) {
                            notCheckedBox()
                        }
                        Text("CAKES BY T")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(0.96)
                            .foregroundStyle(Color("SecondaryText"))
                    }.padding(.horizontal, 25)
                    Spacer()
                    Text("CATEGORY")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(Color("SecondaryText"))
                        .padding(.horizontal, 40)
                }
                
                //ITEMS
                ScrollView (showsIndicators: false){
                    VStack (spacing: 10){
                        VStack(spacing: 0) {
                            ForEach(business.sorted(by: >), id: \.key) { name, price in
                                VStack (spacing: 0){
                                    IndividualItem(name: name, price: price, sortingStage: $sortingStage, categoriesItems: $categoriesItems, selected: $selected, items: $business)
                                    Divider()
                                        .foregroundStyle(Color("SecondaryText"))
                                        .padding(.horizontal, 25)
                                }
                            }
                        }.background(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color("SecondaryText"), lineWidth: 1)
                                .padding(.horizontal, 15)
                        )
                        Rectangle().foregroundStyle(.clear).frame(height: 300)
                    }
                }.clipped()
            }
            // BOTTOM SHEET
            VStack {
                Spacer()
                VStack (spacing: 20){
                    ZStack {
                        Text("Categorize as")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(0.72)
                        HStack {
                            Button(action: {sortingStage = .items}) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20, weight: .bold))
                            }
                            Spacer()
                            if categoriesItems.keys.count == business.keys.count {
                                Button(action: {
                                    sortingStage = .final
                                }) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color("PrimaryGreen"))
                                        .font(.system(size: 20, weight: .bold))
                                }
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
                .padding(.horizontal, 15)
                .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(.black).shadow(color: .black, radius: 4))
            }
            .padding(.horizontal, 20)
        }.navigationBarBackButtonHidden(true)
    }
}

struct ConfirmationSortingView : View {
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
    
    @State var allItems: [String: Double] = [:]
    @State var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @State var expenadedViewMenu: Bool = false
    @State var viewCase: ViewCase = .all
    
    var body: some View {
        VStack (spacing: 15){
            // HEADER (NAME, TOTAL)
            HStack {
                VStack (alignment: .leading, spacing: 15){
                    VStack (alignment: .leading, spacing: 5) {
                        HStack {
                            Text(storeName)
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
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color("SecondaryText"))
                        Text(date)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color("SecondaryText"))
                    }
                    Text("$"+String(format: "%.2f", total))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(greenGradient)
                    HStack (spacing: 15) {
                        if expenadedViewMenu {
                            VStack (spacing: 0){
                                Button(action: {expenadedViewMenu = false}) {
                                    HStack {
                                        Text(viewCase.stringValue)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(Color("CategoryButtonGreen"))
                                        Spacer()
                                        Image(systemName: "chevron.up")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(Color("CategoryButtonGreen"))
                                    }.padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                }
                                Rectangle()
                                    .foregroundStyle(Color("CategoryButtonGreen"))
                                    .frame(height: 1)
                                
                                Button(action: {
                                    viewCase = .all
                                    expenadedViewMenu = false
                                }) {
                                    ZStack {
                                        Rectangle().foregroundStyle(Color("LightGreen"))
                                        HStack {
                                            Text("All")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(.black)
                                            Spacer()
                                        }.padding(.all, 10)
                                    }
                                }
                                Rectangle()
                                    .foregroundStyle(Color("SecondaryText"))
                                    .frame(height: 1)
            
                                Button(action: {
                                    viewCase = .business
                                    expenadedViewMenu = false
                                }) {
                                    ZStack {
                                        Rectangle().foregroundStyle(Color("LightGreen"))
                                        HStack {
                                            Text("Business")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(.black)
                                            Spacer()
                                        }.padding(.all, 10)
                                    }
                                }
                                Rectangle()
                                    .foregroundStyle(Color("SecondaryText"))
                                    .frame(height: 1)
                                
                                Button(action: {
                                    viewCase = .personal
                                    expenadedViewMenu = false
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .foregroundStyle(Color("LightGreen"))
                                            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                                        HStack {
                                            Text("Personal")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(.black)
                                            Spacer()
                                        }.padding(.all, 10)
                                    }
                                }
                            }.frame(width: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("CategoryButtonGreen"), lineWidth: 1)
                                    .frame(width: 120))
                        } else {
                            Button (action: {expenadedViewMenu = true}) {
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color("CategoryButtonGreen"))
                                    HStack {
                                        Text(viewCase.stringValue)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.white)
                                    }.padding(.horizontal, 10)
                                }.frame(width: 120, height: 30)
                            }
                        }
                        
                        Button(action: {sortingStage = .items}) {
                            Image(systemName: "pencil")
                                .font(.system(size: 25, weight: .black))
                                .foregroundStyle(Color("CategoryButtonGreen"))
                        }
                    }
                }
                Spacer()
            }.padding(.horizontal, 30)
                .padding(.top, 20)
            HStack {
                Spacer()
                HStack (spacing: 20){
                    Text("QTY")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(Color("SecondaryText"))
                    Text("PRICE")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(Color("SecondaryText"))
                    Text("CAT")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.96)
                        .foregroundStyle(Color("SecondaryText"))
                }.padding(.trailing, 40)
            }
            ScrollView (showsIndicators: false){
                    VStack(spacing: 0) {
                        ForEach((viewCase == .all ? allItems : (viewCase == .business ? business : personal)).sorted(by: >), id: \.key) { name, price in
                            VStack (spacing: 20){
                                HStack {
                                    Text(name)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.black)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    LazyVGrid(columns: columns) {
                                        Text(String(1))
                                            .font(.system(size: 16))
                                            .foregroundStyle(.black)
                                        Text("$"+String(format: "%.2f", price))
                                            .font(.system(size: 16))
                                            .foregroundStyle(.black)
                                            .lineLimit(1)
                                        if categoriesItems[name] != nil {
                                            Image(systemName: categoriesItems[name] ?? "")
                                                .font(.system(size: 16))
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 25)
                                        } else {
                                            Rectangle()
                                                .foregroundStyle(.clear)
                                                .frame(width: 16)
                                        }
                                    }
                                }
                                Divider()
                                    .foregroundStyle(Color("SecondaryText"))
                            }.padding(.vertical, 10)
                        }.padding(.horizontal, 20)
                }
            }.clipped()
        }.onAppear {
            for key in business.keys {
                allItems[key] = business[key]
            }
            for key in personal.keys {
                allItems[key] = personal[key]
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
