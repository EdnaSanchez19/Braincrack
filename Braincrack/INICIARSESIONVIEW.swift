//
//  INICIARSESIONVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 06/10/25.
//

import SwiftUI

extension INICIARSESION {
    var iniciarsesionview: some View {
        NavigationStack{
            
            ZStack{
                Image("REGISTRARSE")
                    .resizable()
                    .ignoresSafeArea()
                Text(LocalizedStringKey("INICIAR SESIÓN"))
                    .font(.custom("GlacialIndifference-Bold", size: 40))
                    .foregroundColor(Color(red: 1.0, green: 0.5215686274509804, blue: 0.5215686274509804))
                    .padding(.bottom,555)
                Text(LocalizedStringKey("INICIAR SESIÓN"))
                    .font(.custom("GlacialIndifference-Bold", size: 40))
                    .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                    .padding(.bottom,550)
                
                VStack(spacing:5){
                    ZStack{
                        Text(LocalizedStringKey("Usuario"))
                            .font(.custom("GlacialIndifference-Bold", size: 40))
                            .foregroundColor(Color(red: 1.0, green: 0.5215686274509804, blue: 0.5215686274509804))
                            .padding(.trailing, 180)
                        Text(LocalizedStringKey("Usuario"))
                            .font(.custom("GlacialIndifference-Bold", size: 40))
                            .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                            .padding(.trailing, 180)
                    }
                    
                    TextField(LocalizedStringKey("Escriba tu nombre de usuario"), text: $username)
                        .font(.custom("GlacialIndifference-Regular", size: 30))
                        .background(Color(red: 0.9607843137254902, green: 0.9607843137254902, blue: 0.9607843137254902))
                        .frame(width: 350)
                        .cornerRadius(20)
                        .padding(.trailing, 35)
                    
                    
                    ZStack{
                        Text(LocalizedStringKey("Contraseña"))
                            .font(.custom("GlacialIndifference-Bold", size: 40))
                            .foregroundColor(Color(red: 1.0, green: 0.5215686274509804, blue: 0.5215686274509804))
                            .padding(.trailing, 180)
                        Text(LocalizedStringKey("Contraseña"))
                            .font(.custom("GlacialIndifference-Bold", size: 40))
                            .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                            .padding(.trailing, 180)
                    }
                    
                    TextField(LocalizedStringKey("Escribe tu contraseña"), text: $password)
                        .font(.custom("GlacialIndifference-Regular", size: 30))
                        .background(Color(red: 0.9607843137254902, green: 0.9607843137254902, blue: 0.9607843137254902))
                        .frame(width: 350)
                        .cornerRadius(20)
                        .padding(.trailing, 35)
                    
                 
                        Button(action: {
                            
                            
                            
                        }) {
                            NavigationLink(destination: GAMEMODEVIEW()) {
                                Rectangle()
                                    .frame(width: 200, height: 80)
                                    .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                                    .cornerRadius(50)
                                    .overlay(
                                        Text(LocalizedStringKey("ENTRAR"))
                                            .font(.custom("GlacialIndifference-Bold", size: 35))
                                            .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                                        
                                    )
                                    .padding(.top,50)
                                    .padding(.trailing,170)
                                
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    INICIARSESION()
}

