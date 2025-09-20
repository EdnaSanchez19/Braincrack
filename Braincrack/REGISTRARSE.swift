//
//  REGISTRARSE.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 23/09/25.
//

import SwiftUI


struct REGISTRARSE: View {

@State var username: String = " "
@State var password: String = " "
@State var apellido: String = " "
@State var edad: Int = 0
@State var nombre: String = " "
@State private var navegarRegresar = false

    var body: some View {
        ZStack{
            registroView
            
        }
    }
}

#Preview {
    REGISTRARSE()
}
