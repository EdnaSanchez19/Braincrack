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
                    INICIO() // Mostrar INICIO cuando termine
                } else {
                    AnimatedImage(url: GIFS.GIFOPENING())
                        .resizable() // Permite redimensionar
                        .aspectRatio(contentMode: .fill) // Llena toda la pantalla
                        .ignoresSafeArea() // Extiende por toda la pantalla
                }
            }
            .onAppear {
                //main se ejecuta en el hilo principal (UI)
                // asyncAfter ejecutar después de un tiempo
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { //Tiempo para que termine el gif
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
