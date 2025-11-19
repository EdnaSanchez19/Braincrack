//
//  GAMEMODEVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 09/11/25.
//

import SwiftUI

struct GAMEMODEVIEW: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @State var irAInicio = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("MODODEJUEGO")
                    .resizable()
                    .ignoresSafeArea()

                // BOTÓN CERRAR SESIÓN (arriba a la derecha)
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            isLoggedIn = false  // cerrar sesión
                            irAInicio = true
                        } label: {
                            Rectangle()
                                .frame(width: 150, height: 40)
                                .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                                .cornerRadius(50)
                                .overlay(
                                    Text("Cerrar sesión")
                                        .font(.custom("GlacialIndifference-Bold", size: 16))
                                        .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 40)
                    }
                    Spacer()
                }

                Text(LocalizedStringKey("Este modo de juego consiste en ir constestando pregunta por pregunta, en el momento de fallar una pregunta se acaba el juego"))
                    .font(.custom("GlacialIndifference-Bold", size: 19))
                    .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                    .frame(width: 200, height: 190)
                    .padding()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 600)
                    .padding(.leading, 200)
                
                Text(LocalizedStringKey("Muerte Súbita"))
                    .font(.custom("GlacialIndifference-Bold", size: 28))
                    .foregroundColor(Color(red: 1.0, green: 0.5215686274509804, blue: 0.5215686274509804))
                    .frame(width: 200, height: 190)
                    .padding(.trailing,200)
                    .padding(.bottom,750)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey("Muerte Súbita"))
                    .font(.custom("GlacialIndifference-Bold", size: 28))
                    .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                    .frame(width: 200, height: 190)
                    .padding(.trailing,200)
                    .padding(.bottom,745)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey("Serie de pregruntas del tema de preferencia del jugador"))
                    .font(.custom("GlacialIndifference-Bold", size: 20))
                    .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                    .frame(width: 200, height: 180)
                    .padding()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 50)
                    .padding(.trailing, 200)
                
                Text(LocalizedStringKey("Normal"))
                    .font(.custom("GlacialIndifference-Bold", size: 28))
                    .foregroundColor(Color(red: 1.0, green: 0.5215686274509804, blue: 0.5215686274509804))
                    .frame(width: 200, height: 190)
                    .padding(.leading,200)
                    .padding(.bottom,147)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey("Normal"))
                    .font(.custom("GlacialIndifference-Bold", size: 28))
                    .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                    .frame(width: 200, height: 190)
                    .padding(.leading,200)
                    .padding(.bottom,150)
                    .multilineTextAlignment(.center)
               
                Text(LocalizedStringKey("Partida rápida que consiste de obtener puntos contestando correctamente la trivia sin tiempo limite pero con 3 vidas"))
                    .font(.custom("GlacialIndifference-Bold", size: 20))
                    .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                    .frame(width: 200, height: 180)
                    .padding()
                    .multilineTextAlignment(.center)
                    .padding(.top, 555)
                    .padding(.leading, 200)
                
                Text(LocalizedStringKey("Libre"))
                    .font(.custom("GlacialIndifference-Bold", size: 28))
                    .foregroundColor(Color(red: 1.0, green: 0.5215686274509804, blue: 0.5215686274509804))
                    .frame(width: 200, height: 190)
                    .padding(.trailing,210)
                    .padding(.top,347)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey("Libre"))
                    .font(.custom("GlacialIndifference-Bold", size: 28))
                    .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                    .frame(width: 200, height: 190)
                    .padding(.trailing,210)
                    .padding(.top,350)
                    .multilineTextAlignment(.center)
                
                VStack {
                    NavigationLink(destination: MUERTESUBITAVIEW()) {
                        Rectangle()
                            .frame(width: 120, height: 60)
                            .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                            .cornerRadius(50)
                            .overlay(
                                Text(LocalizedStringKey("COMENZAR"))
                                    .font(.custom("GlacialIndifference-Bold", size: 18))
                                    .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                            )
                    }
                    .padding(.bottom, 200)
                    .padding(.trailing,200)

                    NavigationLink(destination: TEMASVIEW()) {
                        Rectangle()
                            .frame(width: 120, height: 60)
                            .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                            .cornerRadius(50)
                            .overlay(
                                Text(LocalizedStringKey("COMENZAR"))
                                    .font(.custom("GlacialIndifference-Bold", size: 18))
                                    .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                            )
                    }
                    .padding(.leading,200)
                    .padding(.bottom, 50)

                    NavigationLink(destination: MUERTESUBITAVIEW()) {
                        Rectangle()
                            .frame(width: 120, height: 60)
                            .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                            .cornerRadius(50)
                            .overlay(
                                Text(LocalizedStringKey("COMENZAR"))
                                    .font(.custom("GlacialIndifference-Bold", size: 18))
                                    .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                            )
                    }
                    .padding(.top,200)
                    .padding(.trailing, 200)
                }
                .padding(.top, 100)
            }
            .navigationDestination(isPresented: $irAInicio) {
                INICIO()
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    GAMEMODEVIEW()
}
