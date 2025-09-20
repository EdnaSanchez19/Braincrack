//
//  INICIARSESION.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 06/10/25.
//

import SwiftUI

struct INICIARSESION: View {
    @State var username: String = " "
    @State var password: String = " "
    @State var apellido: String = " "
    @State var navegarRegresar = false
    
    var body: some View {
        iniciarsesionview
    }
}

#Preview {
    INICIARSESION()
}
