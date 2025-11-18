//
//  INICIARSESION.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 06/10/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct INICIARSESION: View {
    @State var username: String = ""
    @State var password: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @State var errorMessage: String? = nil
    @State var irAGameMode = false

    @State var apellido: String = " "
    @State var navegarRegresar = false

    var body: some View {
        iniciarsesionview
    }
}

#Preview {
    INICIARSESION()
}
