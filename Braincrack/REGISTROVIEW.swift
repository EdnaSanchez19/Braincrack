//
//  REGISTROVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 23/09/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

extension REGISTRARSE {
    
    var registroView: some View {
        NavigationStack {
            ZStack{
                Image("REGISTRARSE")
                    .resizable()
                    .ignoresSafeArea()
                Text(LocalizedStringKey("REGISTRARSE"))
                    .font(.custom("GlacialIndifference-Bold", size: 40))
                    .foregroundColor(Color(red: 1.0, green: 0.5215686, blue: 0.5215686))
                    .padding(.bottom,700)
                Text(LocalizedStringKey("REGISTRARSE"))
                    .font(.custom("GlacialIndifference-Bold", size: 40))
                    .foregroundColor(Color(red: 0.1921569, green: 0.0, blue: 0.3843137))
                    .padding(.bottom,700)
                
                VStack(spacing:5){
                    // ---------- USUARIO ----------
                    ZStack{
                        Text(LocalizedStringKey("Usuario"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 1.0, green: 0.5215686, blue: 0.5215686))
                            .padding(.bottom,15)
                            .padding(.trailing, 220)
                        Text(LocalizedStringKey("Usuario"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 0.1921569, green: 0.0, blue: 0.3843137))
                            .padding(.bottom,10)
                            .padding(.trailing, 220)
                    }
                    TextField(LocalizedStringKey("Escriba su nombre de usuario"), text: $username)
                        .font(.custom("GlacialIndifference-Regular", size: 25))
                        .background(Color(red: 0.9607843, green: 0.9607843, blue: 0.9607843))
                        .frame(width: 350)
                        .cornerRadius(20)
                        .padding(.trailing, 35)
                    
                    // ---------- PASSWORD ----------
                    ZStack{
                        Text(LocalizedStringKey("Contraseña"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 1.0, green: 0.5215686, blue: 0.5215686))
                            .padding(.bottom,15)
                            .padding(.trailing, 220)
                        Text(LocalizedStringKey("Contraseña"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 0.1921569, green: 0.0, blue: 0.3843137))
                            .padding(.bottom,10)
                            .padding(.trailing, 220)
                    }
                    SecureField(LocalizedStringKey("Escriba su contraseña"), text: $password)
                        .font(.custom("GlacialIndifference-Regular", size: 25))
                        .background(Color(red: 0.9607843, green: 0.9607843, blue: 0.9607843))
                        .frame(width: 350)
                        .cornerRadius(20)
                        .padding(.trailing, 35)
                    
                    
                    // ---------- NOMBRE ----------
                    ZStack{
                        Text(LocalizedStringKey("Nombre"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 1.0, green: 0.5215686, blue: 0.5215686))
                            .padding(.bottom,15)
                            .padding(.trailing, 220)
                        Text(LocalizedStringKey("Nombre"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 0.1921569, green: 0.0, blue: 0.3843137))
                            .padding(.bottom,10)
                            .padding(.trailing, 220)
                    }
                    TextField(LocalizedStringKey("Escriba su primer nombre"), text: $nombre)
                        .font(.custom("GlacialIndifference-Regular", size: 25))
                        .background(Color(red: 0.9607843, green: 0.9607843, blue: 0.9607843))
                        .frame(width: 350)
                        .cornerRadius(20)
                        .padding(.trailing, 35)
                    
                    // ---------- APELLIDO ----------
                    ZStack{
                        Text(LocalizedStringKey("Apellido"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 1.0, green: 0.5215686, blue: 0.5215686))
                            .padding(.bottom,15)
                            .padding(.trailing, 220)
                        Text(LocalizedStringKey("Apellido"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 0.1921569, green: 0.0, blue: 0.3843137))
                            .padding(.bottom,10)
                            .padding(.trailing, 220)
                        
                    }
                    TextField(LocalizedStringKey("Escriba su primer apellido"), text: $apellido)
                        .font(.custom("GlacialIndifference-Regular", size: 25))
                        .background(Color(red: 0.9607843, green: 0.9607843, blue: 0.9607843))
                        .frame(width: 350)
                        .cornerRadius(20)
                        .padding(.trailing, 35)
                    
                    // ---------- EDAD ----------
                    ZStack{
                        Text(LocalizedStringKey("Edad"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 1.0, green: 0.5215686, blue: 0.5215686))
                            .padding(.bottom,15)
                            .padding(.trailing, 220)
                        Text(LocalizedStringKey("Edad"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 0.1921569, green: 0.0, blue: 0.3843137))
                            .padding(.bottom,10)
                            .padding(.trailing, 220)
                    }
                    TextField(LocalizedStringKey("Escriba su Edad"), value: $edad, format: .number)
                        .keyboardType(.numberPad)
                        .font(.custom("GlacialIndifference-Regular", size: 25))
                        .background(Color(red: 0.9607843, green: 0.9607843, blue: 0.9607843))
                        .frame(width: 350)
                        .cornerRadius(20)
                        .padding(.trailing, 35)
                    
                    // ---------- FECHA DE NACIMIENTO ----------
                    ZStack{
                        Text(LocalizedStringKey("Cumpleaños"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 1.0, green: 0.5216, blue: 0.5216))
                            .padding(.bottom,15)
                            .padding(.trailing, 180)

                        Text(LocalizedStringKey("Cumpleaños"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                            .padding(.bottom,10)
                            .padding(.trailing, 180)
                    }

                    DatePicker(
                        "",
                        selection: $fechaNacimiento,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .frame(width: 50,height: 50)
                    .padding(.trailing, 35)
                    
                    // ---------- ERROR ----------
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 8)
                            .multilineTextAlignment(.center)
                    }
                    
                    // ---------- BOTÓN REGISTRAR ----------
                    Button(action: {
                        registrarUsuario()
                    }) {
                        Rectangle()
                            .frame(width: 200, height: 80)
                            .foregroundColor(
                                camposInvalidos
                                ? Color.gray.opacity(0.6)
                                : Color(red: 0.187, green: 0.003, blue: 0.381)
                            )
                            .cornerRadius(50)
                            .overlay(
                                Text(LocalizedStringKey("REGISTRAR"))
                                    .font(.custom("GlacialIndifference-Bold", size: 30))
                                    .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                            )
                            .padding(.top, 40)
                            .padding(.trailing, 170)
                    }
                    .disabled(camposInvalidos)
                }
            }
        }
        .navigationDestination(isPresented: $irAGameMode) {
            GAMEMODEVIEW()
        }
    }
    
    // MARK: - Validación
    
    var camposInvalidos: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        apellido.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        edad == nil
    }
    
    // MARK: - Guardar en Firestore y navegar
    
    func registrarUsuario() {
        errorMessage = nil
        
        guard let edad = edad else {
            errorMessage = "Por favor ingresa una edad válida."
            return
        }
        
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "username": username,
            "password": password,
            "name": nombre,
            "last_name": apellido,
            "age": edad,
            "birthday": Timestamp(date: fechaNacimiento),
            "score_sudden_death": 0,
            "score_free": 0,
            "score_data": 0,
            "score_geo": 0,
            "score_math": 0,
            "score_history": 0,
            "score_words": 0
        ]
        
        db.collection("users").addDocument(data: data) { error in
            if let error = error {
                print("Error al registrar usuario: \(error.localizedDescription)")
                errorMessage = "Ocurrió un error al registrar el usuario."
                return
            }
            
            // ✅ Registro OK → marcar sesión y navegar
            isLoggedIn = true
            irAGameMode = true
        }
    }
}

#Preview {
    REGISTRARSE()
}

