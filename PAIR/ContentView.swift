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
    @State var offset: CGFloat = screenSize.width + 15
    
    var body: some View {
        ZStack {
            Color("OnboardingBackground").ignoresSafeArea()
            HStack (spacing: 15) {
                IntroPage(offset: $offset).frame(width: screenSize.width)
                SignUpPage1(offset: $offset).frame(width: screenSize.width)
                SignUpPage2(offset: $offset).frame(width: screenSize.width)
            }.offset(x: self.offset)
        }
    }
}

struct IntroPage: View {
    @Binding var offset: CGFloat
    
    var body: some View {
        VStack (spacing: 25){
            HStack(alignment: .center, spacing: 25) {
                Text("PAIR")
                    .font(Font.custom("CrimsonText-Regular", size: 75))
                    .foregroundStyle(.white)
                Image("PairLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35)
                Spacer()
            }
            Text("Manage receipts effortlessly. Focus on your business, not your paperwork.")
                .font(Font.custom("CrimsonText-Regular", size: 25))
                .foregroundStyle(.white)
            Spacer()
            VStack (spacing: 15){
                Button(action: {self.offset = 0}) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 50)
                            .foregroundStyle(.black)
                        Text("I AM A NEW USER")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                Button(action: {self.offset = 0}) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                        Text("I AM A RETURNING USER")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.black)
                    }
                }
            }
        }.padding(.horizontal, 30)
            .padding(.top, 100)
            .padding(.bottom, 25)
    }
}

struct SignUpPage1: View {
    @Binding var offset: CGFloat
    @State var name: String = ""
    @State var email: String = ""
    @State var phone: String = ""
    @State var alertEmptyField: Bool = false
    
    var body: some View {
        VStack(spacing: 25){
            Image("PairLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35)
            HStack(spacing: 0) {
                ZStack {
                    Circle()
                        .strokeBorder(.white, lineWidth: 1)
                        .frame(width: 21, height: 21)
                    Circle()
                        .fill(.white)
                        .frame(width: 15, height: 15)
                }
                Rectangle()
                    .frame(width:40, height: 1)
                    .foregroundColor(.white)
                Circle()
                    .strokeBorder(.white, lineWidth: 1)
                    .frame(width: 21, height: 21)
            }
            Text("Hello, welcome to Pair!")
                .font(Font.custom("CrimsonText-Regular", size: 30))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            // Text Fields
            VStack (spacing: 20){
                VStack(alignment: .leading, spacing: 6){
                    Text("NAME")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                    ZStack (alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Green"))
                            .frame(height: 55)
                        TextField("", text: $name, prompt: Text("Enter your name")
                            .foregroundStyle(Color.white.opacity(0.6)))
                            .font(.custom("Crimson Text Regular", size: 20))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 15)
                    }
                }
                VStack(alignment: .leading, spacing: 6){
                    Text("EMAIL ADDRESS")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                    ZStack (alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Green"))
                            .frame(height: 55)
                        TextField("", text: $email, prompt: Text("Enter your email address")
                            .foregroundStyle(Color.white.opacity(0.6)))
                            .font(.custom("Crimson Text Regular", size: 20))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 15)
                    }
                }
                VStack(alignment: .leading, spacing: 6){
                    Text("PHONE NUMBER")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                    ZStack (alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Green"))
                            .frame(height: 55)
                        TextField("", text: $phone, prompt: Text("Enter your phone number")
                            .foregroundStyle(Color.white.opacity(0.6)))
                            .font(.custom("Crimson Text Regular", size: 20))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 15)
                            .keyboardType(.numberPad)
                            .textContentType(.telephoneNumber)
                    }
                }
            }
            Spacer()
            HStack {
                // Back Button
                Button(action: {
                    self.offset = screenSize.width + 15
                    dismissKeyboard()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Green"))
                            .frame(width: 170, height: 45)
                        HStack (spacing: 15){
                            Image(systemName: "arrow.left")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                            Text("BACK")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 15)
                    }
                }
                // Next Button
                Button(action: {
                    if name.isEmpty || phone.isEmpty || email.isEmpty {
                        dismissKeyboard()
                        alertEmptyField = true
                    } else {
                        self.offset = -screenSize.width - 15
                        dismissKeyboard()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.black)
                            .frame(width: 170, height: 45)
                        Text("NEXT")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                    }
                }
            }
        }.padding(.horizontal, 30)
            .padding(.vertical, 30)
            .alert("Please make sure to fill out all 3 fields.", isPresented: $alertEmptyField) {
                Button("OK", role: .cancel) { }
            }
            .onTapGesture {
                dismissKeyboard()
            }
    }
}


struct SignUpPage2: View {
    @Binding var offset: CGFloat
    
    @State var menuOpen: Bool = false
    @State var selected: Bool = false
    @State var businessName: String = ""
    
    var body: some View {
        VStack(spacing: 25){
            Image("PairLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35)
            HStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 21, height: 21)
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color("Green"))
                        .font(.system(size: 12, weight: .bold))
                }
                Rectangle()
                    .frame(width:40, height: 1)
                    .foregroundColor(.white)
                ZStack {
                    Circle()
                        .strokeBorder(.white, lineWidth: 1)
                        .frame(width: 21, height: 21)
                    Circle()
                        .fill(.white)
                        .frame(width: 15, height: 15)
                }
            }
            
            Text("One last thing before you’re all set up!")
                .font(Font.custom("CrimsonText-Regular", size: 30))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 6){
                Text("I AM A")
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                Button(action: {
                    if !selected {
                        menuOpen.toggle()
                    }
                }) {
                    ZStack (alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Green"))
                            .frame(height: 55)
                        HStack {
                            Text(selected ? "Business Owner" : "Please select")
                                .font(.custom("Crimson Text Regular", size: 24))
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: menuOpen ? "chevron.down" : "chevron.right")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                        }.padding(.horizontal, 15)
                    }
                }
                if menuOpen && !selected {
                    ZStack (alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(#colorLiteral(red: 0.31940457224845886, green: 0.3794759213924408, blue: 0.31940457224845886, alpha: 1)))
                            .frame(height: 100)
                        VStack (alignment: .leading, spacing: 5) {
                            Button(action: {selected = true }){
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(.clear)
                                        .frame(height: 40)
                                    HStack {
                                        Text("Business Owner")
                                            .font(.custom("Crimson Text Regular", size: 24))
                                            .foregroundStyle(.white)
                                        Spacer()
                                    }
                                }
                            }
                            
                            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                                .frame(height: 1)
                                .foregroundStyle(.white.opacity(0.20))
                            
                            Button(action: {selected = true }){
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(.clear)
                                        .frame(height: 40)
                                    HStack (alignment: .center) {
                                        Text("Employee or Collaborator")
                                            .font(.custom("Crimson Text Regular", size: 24))
                                            .foregroundStyle(.white)
                                        Spacer()
                                    }
                                }
                            }
                        }.padding(.horizontal, 15)
                    }
                }
            }
            
            if selected {
                VStack(alignment: .leading, spacing: 6){
                    Text("THE NAME OF MY BUSINESS IS")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                    ZStack (alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Green"))
                            .frame(height: 55)
                        TextField("", text: $businessName, prompt: Text("Enter business name")
                            .foregroundStyle(Color.white.opacity(0.6)))
                        .font(.custom("Crimson Text Regular", size: 24))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 15)
                    }
                }
                HStack {
                    Text("ADD ANOTHER BUSINESS")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                }
                ZStack {
                    Circle().fill(Color("Green"))
                    Circle().strokeBorder(.white, lineWidth: 1)
                    Image(systemName: "plus")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                }
                .frame(width: 36, height: 36)
            }
            
            Spacer()
            
            HStack {
                // Back Button
                Button(action: {self.offset = 0}) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Green"))
                            .frame(width: 170, height: 45)
                        HStack (spacing: 15){
                            Image(systemName: "arrow.left")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                            Text("BACK")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 15)
                    }
                }
                // Next Button
                NavigationLink(destination: ScanningView()) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.black)
                            .frame(width: 170, height: 45)
                        Text("FINISH")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                    }
                }
            }
            
        }.padding(.horizontal, 30)
            .padding(.vertical, 30)
            .onTapGesture {
                dismissKeyboard()
            }
    }
}

#Preview {
    ContentView()
}
