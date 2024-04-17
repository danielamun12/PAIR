//
//  ContentView.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/10/24.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    @State var imageSelection: PhotosPickerItem? = nil
    @State var loadState: LoadState = .unknown
    
    var body: some View {
        ZStack {
            Color("LightGray").ignoresSafeArea()
            switch loadState {
            case .unknown:
                VStack (spacing: 25){
                    Image("PairLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75)
                    
                    Text("Welcome to PAIR!")
                        .font(Font.custom("CrimsonText-Bold", size: 32, relativeTo: .title))
                }
                VStack {
                    Spacer()
                    PhotosPicker(selection: $imageSelection,
                                 matching: .images) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(height: 65)
                                .foregroundStyle(Color("Green"))
                            Text("Select Receipt")
                                .font(.system(size: 25, weight: .medium))
                                .foregroundStyle(Color("LightGray"))
                        }
                    }.padding(.horizontal, 20)
                }
            case .loaded(let image):
                ZStack{
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.size.width)
                    VStack{
                        HStack {
                            Spacer()
                            Button(action: {
                                imageSelection = nil
                                loadState = .unknown
                            }) {
                                Image(systemName: "x.circle")
                                    .font(.system(size: 25))
                                    .foregroundStyle(.black)
                            }
                        }.padding()
                        Spacer()
                    }.padding()
                }
            case .loading, .failed:
                EmptyView()
            }
            
        }
        .onChange(of: imageSelection) {
            if imageSelection != nil {
                Task {
                    do {
                        loadState = .loading
                        if let image = try await imageSelection?.loadTransferable(type: Image.self) {
                            loadState = .loaded(image)
                        }
                    } catch {
                        loadState = .failed
                    }
                }
            }
        }
    }
}

enum LoadState: Equatable {
    case unknown, loading, loaded(Image), failed
}

#Preview {
    ContentView()
}
