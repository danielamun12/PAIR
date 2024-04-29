//
//  SortingAssets.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/28/24.
//

import SwiftUI

struct IndividualItem : View {
    @State var name: String
    @State var price: Double
    @Binding var sortingStage: SortingStage
    @Binding var categoriesItems: [String: String]
    @Binding var selected: [String: Double]
    @Binding var items: [String: Double]
    
    @State var quantity: Int = 1
    
    
    @State var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        Button(action: {
            if sortingStage != .fullReceipt {
                if selected[name] == price {
                    selected.removeValue(forKey: name)
                } else {
                    selected[name] = price
                }
            }
        }) {
            ZStack {
                if selected[name] == price && sortingStage != .fullReceipt {
                    Rectangle()
                        .cornerRadius(10, corners: items.sorted(by: >).last?.key == name && items.sorted(by: >).first?.key == name ? .allCorners : (items.sorted(by: >).first?.key == name ? [.topLeft, .topRight] : (items.sorted(by: >).last?.key == name ? [.bottomLeft, .bottomRight] : [])))
                        .foregroundStyle(Color(#colorLiteral(red: 0.6360350847244263, green: 0.8230631351470947, blue: 0.6030303835868835, alpha: 1)))
                        .padding(.horizontal, 15)
                }
                HStack {
                    HStack(spacing: 10) {
                        if sortingStage != .fullReceipt {
                            ZStack {
                                Circle()
                                    .strokeBorder(Color.black, lineWidth: 1)
                                    .frame(width: 15)
                                if selected[name] == price {
                                    Circle()
                                        .foregroundStyle(Color(#colorLiteral(red: 0.2834247946739197, green: 0.3737630248069763, blue: 0.2912803292274475, alpha: 1)))
                                        .frame(width: 9)
                                }
                            }
                        }
                        
                        Text(name)
                            .font(.system(size: sortingStage == .fullReceipt ? 20 : 16))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    LazyVGrid(columns: columns) {
                        Text(String(quantity))
                            .font(.system(size: sortingStage == .categories ? 16 : 18, weight: .semibold))
                            .foregroundStyle(.black)
                        // Adjust width for price text to allow longer prices to fit
                        Text("$"+String(format: "%.2f", price))
                            .font(.system(size: sortingStage == .categories ? 16 : 18, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                        if sortingStage == .categories && categoriesItems[name] != nil{
                            Image(systemName: categoriesItems[name]!)
                                .font(.system(size: 18))
                                .foregroundStyle(.black)
                        }
                    }
                }.padding(.horizontal, 25)
                    .padding(.vertical, 10)
            }
        }.onAppear {
            if sortingStage == .categories {
                columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            }
        }
    }
}

struct GroupItems: View {
    @State var groupName: String
    @Binding var sortingStage: SortingStage
    @Binding var items: [String: Double]
    @Binding var selected: [String: Double]
    @Binding var categoriesItems: [String: String]
    
    @State var totalPrice: Double = 0.0
    @State var openList: Bool = false
    
    var body: some View {
        VStack (spacing: 0){
            Button(action: {openList.toggle()}) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(#colorLiteral(red: 0.9239875674247742, green: 0.9689778685569763, blue: 0.9081801772117615, alpha: 1)))
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color(#colorLiteral(red: 0.6719400882720947, green: 0.6256239414215088, blue: 0.6256239414215088, alpha: 1)), lineWidth: 1)
                    HStack (spacing: 15){
                        Image(systemName: openList ? "chevron.down" : "chevron.right")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.black)
                        Text(groupName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.black)
                        Spacer()
                        Text("$"+String(format: "%.2f", totalPrice))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(#colorLiteral(red: 0.32, green: 0.28, blue: 0.28, alpha: 1)))
                    }.padding(.vertical, 15)
                        .padding(.horizontal, 15)
                }.padding(.horizontal, 15)
            }
            if openList {
                ForEach(items.sorted(by: >), id: \.key) { name, price in
                    VStack (spacing: 0){
                        if name == items.keys.sorted(by: >).last {
                            IndividualItem(name: name, price: price, sortingStage: $sortingStage, categoriesItems: $categoriesItems, selected: $selected, items: $items)
                        } else {
                            IndividualItem(name: name, price: price, sortingStage: $sortingStage, categoriesItems: $categoriesItems, selected: $selected, items: $items)
                            Divider()
                                .foregroundStyle(Color(#colorLiteral(red: 0.727246105670929, green: 0.727246105670929, blue: 0.727246105670929, alpha: 1)))
                                .padding(.horizontal, 25)
                        }
                    }
                }
            }
        }.background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color(#colorLiteral(red: 0.727246105670929, green: 0.727246105670929, blue: 0.727246105670929, alpha: 1)), lineWidth: 1)
                .padding(.horizontal, 15)
        )
        .onAppear {
            totalPrice = 0.0
            for (_, price) in items {
                self.totalPrice = totalPrice + price
            }
        }
        .onChange(of: items) {
            totalPrice = 0.0
            for (_, price) in items {
                self.totalPrice = totalPrice + price
            }
        }
    }
}

struct categoryButton: View {
    @State var categoryName: String
    @State var iconName: String
    @Binding var selected: [String: Double]
    @Binding var categoriesItems: [String: String]
    
    let buttonWidth = (screenSize.width-100)/3
    
    var body: some View {
        Button(action: {
            if categoryName != "OTHER" {
                for key in selected.keys {
                    categoriesItems[key] = iconName
                }
                selected = [:]
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: buttonWidth, height: buttonWidth)
                    .foregroundStyle(Color(#colorLiteral(red: 0.31, green: 0.71, blue: 0.35, alpha: 1.00)))
                VStack {
                    if !iconName.isEmpty {
                        Image(systemName: iconName)
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                    Text(categoryName)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .tracking(0.4)
                        .multilineTextAlignment(.center)
                }.frame(width: buttonWidth-10, height: buttonWidth-10)
            }
        }
    }
}
