//
//  TEMASVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 10/11/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct TEMASVIEW: View {
    var body: some View {
        
        ZStack{
            AnimatedImage(url: GIFS.GIFTEMAS())
                .resizable()
                .customLoopCount(0)
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            Text(LocalizedStringKey("Mente Exacta"))
                .font(.custom("GlacialIndifference-Bold", size: 25))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding(.trailing,200)
                .padding(.bottom,760)
                .multilineTextAlignment(.center)
            
            Text(LocalizedStringKey("Ciencias Exactas"))
                .font(.custom("GlacialIndifference-Bold", size: 20))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding()
                .multilineTextAlignment(.center)
                .padding(.bottom, 655)
                .padding(.trailing, 200)
            
            Text(LocalizedStringKey("Letrinas"))
                .font(.custom("GlacialIndifference-Bold", size: 28))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding()
                .multilineTextAlignment(.center)
                .padding(.bottom, 760)
                .padding(.leading, 200)
            
            Text(LocalizedStringKey("Definiciones"))
                .font(.custom("GlacialIndifference-Bold", size: 20))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding()
                .multilineTextAlignment(.center)
                .padding(.bottom, 655)
                .padding(.leading, 200)
            
            Text(LocalizedStringKey("Chismes del Tiempo"))
                .font(.custom("GlacialIndifference-Bold", size: 28))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding()
                .multilineTextAlignment(.center)
                .padding(.bottom, 210)
                .padding(.leading, 200)
            
            Text(LocalizedStringKey("Historia Universal"))
                .font(.custom("GlacialIndifference-Bold", size: 20))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding()
                .multilineTextAlignment(.center)
                .padding(.bottom, 60)
                .padding(.leading, 200)
            
            Text(LocalizedStringKey("GeoExplora"))
                .font(.custom("GlacialIndifference-Bold", size: 28))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding(.trailing,200)
                .padding(.top,330)
                .multilineTextAlignment(.center)
            
            Text(LocalizedStringKey("Geografía"))
                .font(.custom("GlacialIndifference-Bold", size: 20))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding()
                .multilineTextAlignment(.center)
                .padding(.top, 450)
                .padding(.trailing, 200)
            
            Text(LocalizedStringKey("Dati Nauta"))
                .font(.custom("GlacialIndifference-Bold", size: 28))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding()
                .multilineTextAlignment(.center)
                .padding(.top, 330)
                .padding(.leading, 200)
            
            Text(LocalizedStringKey("Datos Culturales"))
                .font(.custom("GlacialIndifference-Bold", size: 20))
                .foregroundColor(Color(red: 0.19215686274509805, green: 0.0, blue: 0.3843137254901961))
                .padding()
                .multilineTextAlignment(.center)
                .padding(.top, 450)
                .padding(.leading, 200)
            
            VStack {
                HStack{
                    NavigationLink(destination: MENTEEXACTAVIEW()) {
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
                    .padding(.trailing,100)
                    
                    NavigationLink(destination: LETRINASVIEW()) {
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
                }.padding(.top,80)
                   
               
                NavigationLink(destination: CHISMEVIEW()) {
                    Rectangle()
                        .frame(width: 120, height: 60)
                        .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                        .cornerRadius(50)
                        .overlay(
                            Text(LocalizedStringKey("COMENZAR"))
                                .font(.custom("GlacialIndifference-Bold", size: 18))
                                .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                        )
                       
                }.padding(.leading,200)
                    .padding(.top, 200)

                HStack{
                NavigationLink(destination: GEOEXPLORAVIEW()) {
                    Rectangle()
                        .frame(width: 120, height: 60)
                        .foregroundColor(Color(red: 0.187, green: 0.003, blue: 0.381))
                        .cornerRadius(50)
                        .overlay(
                            Text(LocalizedStringKey("COMENZAR"))
                                .font(.custom("GlacialIndifference-Bold", size: 18))
                                .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                        )
                }.padding(.trailing,100)
                
                NavigationLink(destination: DATONAUTAVIEW()) {
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
                }.padding(.top,200)
            }
            
        }
    }
}

#Preview {
    TEMASVIEW()
}
