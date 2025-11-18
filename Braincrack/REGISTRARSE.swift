//
//  REGISTRARSE.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 23/09/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct REGISTRARSE: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var nombre: String = ""
    @State var apellido: String = ""
    @State var edad: Int? = nil
    @State var fechaNacimiento: Date = Date()
    
    @AppStorage("isLoggedIn") var isLoggedIn = false   // 👈 para marcar sesión iniciada
    @State var errorMessage: String? = nil
    @State var irAGameMode = false  
    
    var body: some View {
        ZStack{
            registroView
        }
    }
}

#Preview {
    REGISTRARSE()
}
