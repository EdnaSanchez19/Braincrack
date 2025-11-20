//
//  BraincrackApp.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 20/09/25.
//

import SwiftUI
import FirebaseCore

@main
struct BraincrackApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "es"
    
    @State private var mostrarSplash = true

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
               
                Image("cerebro")
                    .resizable()
                    .ignoresSafeArea()
                    
                
                if mostrarSplash {
                    SplashScreenView()
                        .transition(.identity)
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                mostrarSplash = false
                            }
                        }
                } else {
                    INICIOOPENING()
                        .environment(\.locale, Locale(identifier: selectedLanguage))
                        .transition(.identity)
                }
            }
            .animation(.none, value: mostrarSplash)
        }
    }
}

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Image("cerebro")
                .resizable()
                .ignoresSafeArea()
            
        }
    }
}
