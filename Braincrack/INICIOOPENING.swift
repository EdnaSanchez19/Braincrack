//
//  ContentView.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 20/09/25.
//

import SwiftUI
import SDWebImageSwiftUI


struct INICIOOPENING: View {
    @State var animacionterminada: Bool = false
    @State var inicioanimacion: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if animacionterminada == true {
                    INICIO() 
                } else {
                    AnimatedImage(url: GIFS.GIFOPENING())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                }
            }
            .onAppear {
                
                // asyncAfter ejecutar después de un tiempo
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        animacionterminada = true
                    }
                }
            }
        }
    }
}

#Preview {
    INICIOOPENING()
}
