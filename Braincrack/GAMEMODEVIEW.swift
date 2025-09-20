//
//  GAMEMODEVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 09/11/25.
//

import SwiftUI

struct GAMEMODEVIEW: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("MODODEJUEGO")
                    .resizable()
                    .ignoresSafeArea()
                Button(action: {
                    
                }) {
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
                            .padding(.bottom, 540)
                            .padding(.trailing, 200)
                    }
                }
                
                Button(action: {
                    
                }) {
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
                            .padding(.bottom, 10)
                            .padding(.leading, 200)
                    }
                }
                
                Button(action: {
                    
                }) {
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
                            .padding(.top, 540)
                            .padding(.trailing, 200)
                    }
                }
            }
        }
    }
}

#Preview {
    GAMEMODEVIEW()
}
