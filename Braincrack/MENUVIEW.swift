//
//  MENUVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 30/09/25.
//

import SwiftUI

struct MENUVIEW: View {
    @State private var navegarARegistro = false
    @State private var navegarAIniciarSesion = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("INICIO")
                    .resizable()
                    .ignoresSafeArea()
                
                
                VStack {
                    // Botón de iniciar sesión
                    Button(action: {
                        navegarAIniciarSesion = true
                    }) {
                        Rectangle()
                            .frame(width: 300, height: 80)
                            .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                            .cornerRadius(50)
                            .overlay(
                                Text(LocalizedStringKey("INICIAR SESIÓN"))
                                    .font(.custom("GlacialIndifference-Bold", size: 35))
                                    .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                            )
                            .padding(.top, 50)
                    }
                    .navigationDestination(isPresented: $navegarAIniciarSesion) {
                        INICIARSESION()
                    }
                    
                    // Botón de registrarse
                    Button(action: {
                        navegarARegistro = true
                    }) {
                        Rectangle()
                            .frame(width: 300, height: 80)
                            .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                            .cornerRadius(50)
                            .overlay(
                                Text(LocalizedStringKey("REGISTRARSE"))
                                    .font(.custom("GlacialIndifference-Bold", size: 35))
                                    .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                            )
                            .padding(.top, 50)
                    }
                    .navigationDestination(isPresented: $navegarARegistro) {
                        REGISTRARSE()
                    }
                }
            }
        }
    }
}
#Preview {
    MENUVIEW()
}
