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
    @State private var showLanguagePicker = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "es" // Idioma predeterminado en español

    var body: some View {
        NavigationStack {
            ZStack {
                // Imagen animada de fondo
                AnimatedImage(url: GIFS.GIFINICIO())
                    .resizable()
                    .customLoopCount(0)
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()

                VStack {
                    // Botón de "COMENZAR"
                    Button(action: {
                        navegarARegistro = true
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
                    .navigationDestination(isPresented: $navegarARegistro) {
                        MENUVIEW() // Se navega a la vista MENUVIEW
                    }

                    // Botón circular para seleccionar el idioma (Globo)
                    Button(action: {
                        showLanguagePicker.toggle() // Abre el popup para elegir el idioma
                    }) {
                        Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                            .cornerRadius(50)
                            .overlay(
                                Image(systemName: "globe") // Icono de globo
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                            )
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 50) // Ajusta la posición según sea necesario
                }
            }
            .sheet(isPresented: $showLanguagePicker) {
                VStack {
                    Text(LocalizedStringKey("Selecciona un idioma"))
                        .font(.title)
                        .padding()

                    Button(action: {
                        setLanguage("en") // Cambia a inglés
                        showLanguagePicker = false
                    }) {
                        Text(LocalizedStringKey("Inglés"))
                            .font(.title2)
                            .padding()
                    }

                    Button(action: {
                        setLanguage("es") // Cambia a español
                        showLanguagePicker = false
                    }) {
                        Text(LocalizedStringKey("Español"))
                            .font(.title2)
                            .padding()
                    }

                    Button(action: {
                        setLanguage("de") // Cambia a alemán
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
        .environment(\.locale, Locale(identifier: selectedLanguage)) // Aplica el idioma seleccionado globalmente
    }

    func setLanguage(_ languageCode: String) {
        selectedLanguage = languageCode // Guarda el idioma seleccionado
        // No es necesario hacer más, ya que @AppStorage sincroniza automáticamente el valor
    }
}

#Preview {
    INICIO()
}
