//
//  INICIO VIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 22/09/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct INICIO: View {
    @State private var navegarARegistro = false
    @State private var navegarAGameMode = false
    @State private var showLanguagePicker = false
    @AppStorage("selectedLanguage") var selectedLanguage = "es"
    @AppStorage("isLoggedIn") var isLoggedIn = false 

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedImage(url: GIFS.GIFINICIO())
                    .resizable()
                    .customLoopCount(0)
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()

                VStack {
                    Button(action: {
                        
                        if isLoggedIn {
                            navegarAGameMode = true // Si esta log ir a GAMEMODEVIEW
                        } else {
                            navegarARegistro = true // Si no esta logueado ir a MENUVIEW
                        }
                    }) {
                        Rectangle()
                            .frame(width: 300, height: 80)
                            .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                            .cornerRadius(50)
                            .overlay(
                                Text(LocalizedStringKey("COMENZAR"))
                                    .font(.custom("GlacialIndifference-Bold", size: 40))
                                    .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                            )
                            .padding(.top, 200)
                    }
                    .navigationDestination(isPresented: $navegarAGameMode) {
                        GAMEMODEVIEW().transition(.fade(duration: 5))
                    }
                    .navigationDestination(isPresented: $navegarARegistro) {
                        MENUVIEW()
                    }

                    Button(action: {
                        showLanguagePicker.toggle()
                    }) {
                        Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                            .cornerRadius(50)
                            .overlay(
                                Image(systemName: "globe")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                            )
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 50)
                }
            }
            .sheet(isPresented: $showLanguagePicker) {
                VStack {
                    Text(LocalizedStringKey("Selecciona un idioma"))
                        .font(.title)
                        .padding()

                    Button(action: {
                        setLanguage("en")
                        showLanguagePicker = false
                    }) {
                        Text(LocalizedStringKey("Inglés"))
                            .font(.title2)
                            .padding()
                    }

                    Button(action: {
                        setLanguage("es")
                        showLanguagePicker = false
                    }) {
                        Text(LocalizedStringKey("Español"))
                            .font(.title2)
                            .padding()
                    }

                    Button(action: {
                        setLanguage("de")
                        showLanguagePicker = false
                    }) {
                        Text(LocalizedStringKey("Alemán"))
                            .font(.title2)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(20)
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguage))
    }

    func setLanguage(_ languageCode: String) {
        selectedLanguage = languageCode
    }
}

#Preview {
    INICIO()
}
