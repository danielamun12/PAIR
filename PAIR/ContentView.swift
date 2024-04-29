//
//  ContentView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/10/24.
//

import SwiftUI

struct ContentView: View {
    @State var page: Int = 0
    var body: some View {
        NavigationView {
            if page == 0 {
                ReceiptTypeSelection(page: $page)
            } else {
                ReceiptSourceSelection(page: $page)
            }
        }.onAppear{sendReceiptNotification()}
    }
}

struct ReceiptTypeSelection: View {
    @Binding var page: Int
    var body: some View {
        ZStack {
            appBackground()
            VStack (spacing: 10){
                // X BUTTON
                HStack {
                    Spacer()
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.black)
                }
                // TITLE QUESTSTION
                HStack {
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Was this a business transaction?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.black)
                        Text("Business receipts will be itemized")
                            .font(.system(size: 16))
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }
                Spacer()
                // PURCHASE INFO
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.black, lineWidth: 1)
                    VStack {
                        HStack {
                            Text("Giant Eagle")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.black)
                            Spacer()
                            Text("Today\n9:41am")
                                .font(.system(size: 16))
                                .foregroundStyle(.black.opacity(0.75))
                                .multilineTextAlignment(.trailing)
                        }
                        Spacer()
                        HStack {
                            Text("$56.98")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.black)
                            Spacer()
                        }
                    }.padding(.all, 20)
                }.frame(width: 265, height: 265)
                Spacer()
                // BUTTONS
                VStack (spacing: 15) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.black)
                            .frame(width: 265, height: 45)
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("PERSONAL")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                        }.padding(.horizontal, 15)
                    }.frame(width: 265, height: 45)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.black)
                            .frame(width: 265, height: 45)
                        HStack {
                            Image("PairLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 18)
                            Spacer()
                            Text("BUSINESS")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                        }.padding(.horizontal, 15)
                    }.frame(width: 265, height: 45)
                    
                    Button(action: {page = 1}){
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(greenGradient)
                            HStack {
                                Image(systemName: "arrow.triangle.branch")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("MIXED")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                Spacer()
                            }.padding(.horizontal, 15)
                        }.frame(width: 265, height: 45)
                    }
                }
            }.padding(.vertical, 20)
                .padding(.horizontal, 20)
        }
    }
}

struct ReceiptSourceSelection: View {
    @Binding var page: Int
    var body: some View {
        ZStack {
            appBackground()
            VStack (spacing: 10){
                // X BUTTON
                Button(action: {page = 0}) {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(.black)
                    }
                }
                // TITLE QUESTSTION
                HStack {
                    VStack (alignment: .leading, spacing: 10) {
                        Text("How did you receive the receipt?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.black)
                        Text("")
                            .font(.system(size: 16))
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }
                Spacer()
                // PURCHASE INFO
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(greenGradient)
                    VStack {
                        HStack (alignment: .top) {
                            Text("Giant Eagle")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("Today\n9:41am")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.75))
                                .multilineTextAlignment(.trailing)
                        }
                        Spacer()
                        HStack {
                            Text("$56.98")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                        }
                    }.padding(.all, 20)
                }.frame(width: 265, height: 265)
                Spacer()
                // BUTTONS
                VStack (spacing: 15) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(.black, lineWidth: 1)
                            .frame(width: 265, height: 45)
                        HStack {
                            Image(systemName: "envelope")
                                .font(.system(size: 18))
                                .foregroundStyle(.black)
                            Spacer()
                            Text("EMAIL")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.black)
                            Spacer()
                        }.padding(.horizontal, 15)
                    }.frame(width: 265, height: 45)
                    
                    NavigationLink(destination: SortingView()){
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(.black, lineWidth: 1)
                            HStack {
                                Image(systemName: "scroll")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.black)
                                Spacer()
                                Text("PHYSICAL RECEIPT")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.black)
                                Spacer()
                            }.padding(.horizontal, 15)
                        }.frame(width: 265, height: 45)
                    }
                }
            }.padding(.top, 20)
                .padding(.bottom, 65)
                .padding(.horizontal, 20)
        }
    }
}
