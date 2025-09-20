//
//  REGISTROVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 23/09/25.
//

import SwiftUI

extension REGISTRARSE {
    
    var registroView: some View {
        ZStack{
            Image("REGISTRARSE")
                .resizable()
                .ignoresSafeArea()
            Text(LocalizedStringKey("REGISTRARSE"))
                .font(.custom("GlacialIndifference-Bold", size: 40))
                .foregroundColor(Color(red: 1.0, green: 0.5215686274509804, blue: 0.5215686274509804))
                .padding(.bottom,555)
            Text(LocalizedStringKey("REGISTRARSE"))
                .font(.custom("GlacialIndifference-Bold", size: 40))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding(.bottom,550)
            
            VStack(spacing:5){
                ZStack{
                    Text(LocalizedStringKey("Nombre"))
                        .font(.custom("GlacialIndifference-Bold", size: 40))
                        .foregroundColor(Color(red: 1.0, green: 0.5215686274509804, blue: 0.5215686274509804))
                        .padding(.bottom,15)
                        .padding(.trailing, 220)
                    Text(LocalizedStringKey("Nombre"))
                        .font(.custom("GlacialIndifference-Bold", size: 40))
                        .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                        .padding(.bottom,10)
                        .padding(.trailing, 220)
                }
                TextField(LocalizedStringKey("Escriba su primer nombre"), text: $nombre)
                    .font(.custom("GlacialIndifference-Regular", size: 30))
                    .background(Color(red: 0.9607843137254902, green: 0.9607843137254902, blue: 0.9607843137254902))
                    .frame(width: 350)
                    .cornerRadius(20)
                    .padding(.trailing, 35)
                
                ZStack{
                    Text(LocalizedStringKey("Apellido"))
                        .font(.custom("GlacialIndifference-Bold", size: 40))
                        .foregroundColor(Color(red: 1.0, green: 0.5215686274509804, blue: 0.5215686274509804))
                        .padding(.bottom,15)
                        .padding(.trailing, 220)
                    Text(LocalizedStringKey("Apellido"))
                        .font(.custom("GlacialIndifference-Bold", size: 40))
                        .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                        .padding(.bottom,10)
                        .padding(.trailing, 220)
                    
                }
                TextField(LocalizedStringKey("Escriba su primer apellido"), text: $apellido)
                    .font(.custom("GlacialIndifference-Regular", size: 30))
                    .background(Color(red: 0.9607843137254902, green: 0.9607843137254902, blue: 0.9607843137254902))
                    .frame(width: 350)
                    .cornerRadius(20)
                    .padding(.trailing, 35)
                
                ZStack{
                    Text(LocalizedStringKey("Edad"))
                        .font(.custom("GlacialIndifference-Bold", size: 40))
                        .foregroundColor(Color(red: 1.0, green: 0.5215686274509804, blue: 0.5215686274509804))
                        .padding(.bottom,15)
                        .padding(.trailing, 220)
                    Text(LocalizedStringKey("Edad"))
                        .font(.custom("GlacialIndifference-Bold", size: 40))
                        .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                        .padding(.bottom,10)
                        .padding(.trailing, 220)
                }
                TextField(LocalizedStringKey("Escriba su Edad"), value: $edad, format: .number)
                    .keyboardType(.numberPad)
                    .font(.custom("GlacialIndifference-Regular", size: 30))
                    .background(Color(red: 0.9607843137254902, green: 0.9607843137254902, blue: 0.9607843137254902))
                    .frame(width: 350)
                    .cornerRadius(20)
                    .padding(.trailing, 35)
            }
        }
    }
}

#Preview {
    REGISTRARSE()
}

