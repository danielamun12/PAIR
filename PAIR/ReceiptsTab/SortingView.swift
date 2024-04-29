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
    @Binding var receipt: String?
    @State var businessItmes: [[String]] = []
    @State var personalItems: [String] = []
    @State var image: UIImage? = nil
    
    @State private var receiptObservations: [String] = []
    
    var body: some View {
        ZStack {
            appBackground()
            if image == nil {
                IDReceiptType(receipt: $receipt, image: $image, receiptObservations: $receiptObservations)
            } else {
                ReceiptSortingView(receipt: $receipt, image: $image, receiptObservations: $receiptObservations)
            }
        }
    }
}

struct IDReceiptType: View {
    @Binding var receipt: String?
    @Binding var image: UIImage?
    @Binding var receiptObservations: [String]
    
    var body: some View {
        ZStack {
            appBackground()
            VStack {
                Spacer()
                Text("Total transaction amount")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(#colorLiteral(red: 0.4, green: 0.38, blue: 0.35, alpha: 1)))
                Text("$95.43")
                    .font(.custom("Crimson Text Regular", size: 64))
                    .foregroundStyle(.black)
                Text("How did you receive the receipt to your transaction?")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("PrimaryButton"))
                        .frame(height: 50)
                    
                    Text("EMAIL")
                        .font(.custom("Manrope Bold", size: 16))
                        .foregroundStyle(.white)
                }
                NavigationLink(destination: CameraView(camera: CameraModel(), image: $image, stringResults: $receiptObservations)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("PrimaryButton"))
                            .frame(height: 50)
                        
                        Text("PAPER")
                            .font(.custom("Manrope Bold", size: 16))
                            .foregroundStyle(.white)
                    }
                }
                Spacer()
                Text("DO IT LATER ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(#colorLiteral(red: 0.45, green: 0.4, blue: 0.33, alpha: 1)))
            }.padding(.horizontal, 30)
        }
    }
}

struct ReceiptSortingView: View {
    @Binding var receipt: String?
    @Binding var image: UIImage?
    @Binding var receiptObservations: [String]
    
    @State var storeName: String = ""
    @State var date: String = ""
    @State var items: [String: Double] = [:]
    @State var subtotal: Double = 0.0
    @State var tax: Double = 0.0
    @State var total: Double = 0.0
    
    
    //SORTING
    @State var sortingStage: SortingStage = .loading
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
                FullReceiptSortingView(storeName: storeName, date: date, items: items, subtotal: subtotal, tax: tax, total: total, sortingStage: $sortingStage, selected: $selected, business: $business, personal: $personal, categoriesItems: $categoriesIems)
            case .items:
                ItemSortingView(storeName: storeName, date: date, items: items, subtotal: subtotal, tax: tax, total: total, sortingStage: $sortingStage, selected: $selected, business: $business, personal: $personal, categoriesItems: $categoriesIems)
            case .categories:
                CategorySortingView(storeName: storeName, date: date, items: items, subtotal: subtotal, tax: tax, total: total, sortingStage: $sortingStage, selected: $selected, business: $business, personal: $personal, categoriesItems: $categoriesIems)
            }
        }.onAppear {
            (storeName, date, items, subtotal, tax, total) = extractReceiptInfo(receipt: receiptObservations)
            sortingStage = .fullReceipt
        }
    }
}

struct FullReceiptSortingView: View {
    @State var storeName: String
    @State var date: String
    @State var items: [String: Double]
    @State var subtotal: Double
    @State var tax: Double
    @State var total: Double
    @Binding var sortingStage: SortingStage
    
    //SORTING
    @Binding var selected: [String: Double]
    @Binding var business: [String: Double]
    @Binding var personal: [String: Double]
    @Binding var categoriesItems: [String: String]
    
    var body: some View {
        VStack (spacing: 15){
            // HEADER (NAME, DATE, TOTAL)
            HStack {
                VStack (alignment: .leading, spacing: 35) {
                    VStack (alignment: .leading, spacing: 5) {
                        Text(storeName.prefix(1).capitalized + storeName.dropFirst())
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                        HStack (spacing: 25){
                            Text(date)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                            Text("Paid by Visa xxxx xxxx xxxx 5612")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                        }
                    }.padding(.horizontal, 30)
                    
                    VStack (alignment: .leading, spacing: 5) {
                        Text("Total Amount")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white)
                        Text("$"+String(format: "%.2f", total))
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    }.padding(.horizontal, 30)
                }.padding(.top, 35)
                    .padding(.bottom, 20)
                Spacer()
            }.background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                    gradient: Gradient(stops: [
                                .init(color: Color(#colorLiteral(red: 0.24313725531101227, green: 0.6941176652908325, blue: 0.2823529541492462, alpha: 1)), location: 0),
                                .init(color: Color(#colorLiteral(red: 0.612762987613678, green: 0.821533203125, blue: 0.5394119620323181, alpha: 1)), location: 1)]),
                                    startPoint: UnitPoint(x: 0.02808989848203508, y: 0.05072464031020463),
                                    endPoint: UnitPoint(x: 0.999999972366374, y: 0.9758455178655459)))
                            .padding(.horizontal, 15)
                    )
            
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
                    ForEach(items.sorted(by: >), id: \.key) {name, price in
                        VStack (spacing: 0){
                            IndividualItem(name: name, price: price, sortingStage: $sortingStage, categoriesItems: $categoriesItems, selected: $selected, items: $items)
                            if !(items.sorted(by: >).last?.key == name) {
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
                    
                    Rectangle().foregroundStyle(.clear).frame(height: 25)
            }.clipped()
        }.padding(.bottom, 150)
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
            }.padding(.top, 15)
                .padding(.bottom, 25)
                .padding(.horizontal, 30)
            .background(RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(#colorLiteral(red: 0.3849477469921112, green: 0.8138183355331421, blue: 0.42224085330963135, alpha: 1)), location: 0),
                        .init(color: Color(#colorLiteral(red: 0.5774057507514954, green: 0.8213704228401184, blue: 0.5986198782920837, alpha: 1)), location: 1)]),
                    startPoint: UnitPoint(x: 0.011235987979254458, y: 0.02209937045779875),
                    endPoint: UnitPoint(x: 0.9803370915035547, y: 0.9640884194913579)))
                .frame(width: screenSize.width))
        }.ignoresSafeArea(edges: .bottom)
    }
}

struct ItemSortingView: View {
    @State var storeName: String
    @State var date: String
    @State var items: [String: Double]
    @State var subtotal: Double
    @State var tax: Double
    @State var total: Double
    @Binding var sortingStage: SortingStage
    
    //SORTING
    @Binding var selected: [String: Double]
    @Binding var business: [String: Double]
    @Binding var personal: [String: Double]
    @Binding var categoriesItems: [String: String]
    
    var body: some View {
        VStack (spacing: 15){
            // HEADER (NAME, TOTAL)
            HStack {
                VStack (alignment: .leading, spacing: 5) {
                    Text(storeName.prefix(1).capitalized + storeName.dropFirst())
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("$"+String(format: "%.2f", total))
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }.padding(.horizontal, 30)
                    .padding(.vertical, 10)
                Spacer()
            }.background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                    gradient: Gradient(stops: [
                                .init(color: Color(#colorLiteral(red: 0.24313725531101227, green: 0.6941176652908325, blue: 0.2823529541492462, alpha: 1)), location: 0),
                                .init(color: Color(#colorLiteral(red: 0.612762987613678, green: 0.821533203125, blue: 0.5394119620323181, alpha: 1)), location: 1)]),
                                    startPoint: UnitPoint(x: 0.02808989848203508, y: 0.05072464031020463),
                                    endPoint: UnitPoint(x: 0.999999972366374, y: 0.9758455178655459)))
                            .padding(.horizontal, 15)
                    )
            Text("SELECT THE ITEMS YOU WANT TO SORT")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.black)
            
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
                        ForEach(items.sorted(by: >), id: \.key) { name, price in
                            VStack (spacing: 0){
                                IndividualItem(name: name, price: price, sortingStage: $sortingStage, categoriesItems: $categoriesItems, selected: $selected, items: $items)
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
                    Rectangle().foregroundStyle(.clear).frame(height: 25)
                }
            }.clipped()
        }.padding(.bottom, 95)
        VStack {
            Spacer()
                VStack (spacing: 20){
                    ZStack {
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
                        }
                        Text("SORT SELECTED AS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(0.84)
                    }
                    HStack (spacing: 15){
                        Button(action: {
                            for key in selected.keys {
                                business.removeValue(forKey: key)
                                items.removeValue(forKey: key)
                            }
                            personal.merge(selected) { (_, new) in new }
                            selected = [:]
                            if items.keys.isEmpty {
                                sortingStage = .categories
                            }
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
                                items.removeValue(forKey: key)
                            }
                            business.merge(selected) { (_, new) in new }
                            selected = [:]
                            if items.keys.isEmpty {
                                sortingStage = .categories
                            }
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
                .fill(LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(#colorLiteral(red: 0.3849477469921112, green: 0.8138183355331421, blue: 0.42224085330963135, alpha: 1)), location: 0),
                        .init(color: Color(#colorLiteral(red: 0.5774057507514954, green: 0.8213704228401184, blue: 0.5986198782920837, alpha: 1)), location: 1)]),
                    startPoint: UnitPoint(x: 0.011235987979254458, y: 0.02209937045779875),
                    endPoint: UnitPoint(x: 0.9803370915035547, y: 0.9640884194913579)))
                .frame(width: screenSize.width))
        }.ignoresSafeArea(edges: .bottom)
    }
}

struct CategorySortingView: View {
    @State var storeName: String
    @State var date: String
    @State var items: [String: Double]
    @State var subtotal: Double
    @State var tax: Double
    @State var total: Double
    @Binding var sortingStage: SortingStage
    
    //SORTING
    @Binding var selected: [String: Double]
    @Binding var business: [String: Double]
    @Binding var personal: [String: Double]
    @Binding var categoriesItems: [String: String]
    
    var body: some View {
        VStack (spacing: 15){
            // HEADER (NAME, TOTAL)
            HStack {
                VStack (alignment: .leading, spacing: 5) {
                    Text(storeName.prefix(1).capitalized + storeName.dropFirst())
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("$"+String(format: "%.2f", total))
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }.padding(.horizontal, 30)
                    .padding(.vertical, 10)
                Spacer()
            }.background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                    gradient: Gradient(stops: [
                                .init(color: Color(#colorLiteral(red: 0.24313725531101227, green: 0.6941176652908325, blue: 0.2823529541492462, alpha: 1)), location: 0),
                                .init(color: Color(#colorLiteral(red: 0.612762987613678, green: 0.821533203125, blue: 0.5394119620323181, alpha: 1)), location: 1)]),
                                    startPoint: UnitPoint(x: 0.02808989848203508, y: 0.05072464031020463),
                                    endPoint: UnitPoint(x: 0.999999972366374, y: 0.9758455178655459)))
                            .padding(.horizontal, 15)
                    )
            Text("SELECT THE ITEMS YOU WANT TO SORT")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.black)
            
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
                    Rectangle().foregroundStyle(.clear).frame(height: 25)
                }
            }.clipped()
        }.padding(.bottom, 250)
        VStack {
            Spacer()
                VStack (spacing: 20){
                    ZStack {
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
                        }
                        Text("CATEGORIZE SELECTED AS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(0.84)
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
                .fill(LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(#colorLiteral(red: 0.3849477469921112, green: 0.8138183355331421, blue: 0.42224085330963135, alpha: 1)), location: 0),
                        .init(color: Color(#colorLiteral(red: 0.5774057507514954, green: 0.8213704228401184, blue: 0.5986198782920837, alpha: 1)), location: 1)]),
                    startPoint: UnitPoint(x: 0.011235987979254458, y: 0.02209937045779875),
                    endPoint: UnitPoint(x: 0.9803370915035547, y: 0.9640884194913579)))
                .frame(width: screenSize.width))
        }.ignoresSafeArea(edges: .bottom)
    }
}
