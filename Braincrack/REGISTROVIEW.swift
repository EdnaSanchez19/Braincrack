//
//  REGISTROVIEW.swift - CORREGIDO CON FIREBASE AUTH
//  Braincrack
//
//  Created by Edna Sanchez  on 23/09/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

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
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
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
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
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
                    
                    // ---------- EMAIL ----------
                    ZStack{
                        Text(LocalizedStringKey("Email"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 1.0, green: 0.5215686, blue: 0.5215686))
                            .padding(.bottom,15)
                            .padding(.trailing, 220)
                        Text(LocalizedStringKey("Email"))
                            .font(.custom("GlacialIndifference-Bold", size: 25))
                            .foregroundColor(Color(red: 0.1921569, green: 0.0, blue: 0.3843137))
                            .padding(.bottom,10)
                            .padding(.trailing, 220)
                    }
                    TextField(LocalizedStringKey("Escriba su Email"), text: $email)
                        .keyboardType(.emailAddress)
                        .font(.custom("GlacialIndifference-Regular", size: 25))
                        .background(Color(red: 0.9607843, green: 0.9607843, blue: 0.9607843))
                        .frame(width: 350)
                        .cornerRadius(20)
                        .padding(.trailing, 35)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    // ---------- ERROR MESSAGE ----------
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
        let usernameVacio = username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let passwordVacio = password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let nombreVacio = nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let apellidoVacio = apellido.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailVacio = email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let edadVacia = edad == nil
        
        return usernameVacio || passwordVacio || nombreVacio || apellidoVacio || emailVacio || edadVacia
    }
    
    // MARK: - Guardar en Firebase Auth Y Firestore
    
    func registrarUsuario() {
        errorMessage = nil
        
        guard let edad = edad else {
            errorMessage = "Por favor ingresa una edad válida."
            return
        }
        
        // Validar email
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Por favor ingresa un email válido."
            return
        }
        
        // Validar contraseña (Firebase requiere mínimo 6 caracteres)
        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            return
        }
        
        // PASO 1: Crear usuario en Firebase Auth
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("❌ Error al crear usuario en Auth: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    errorMessage = "Error al crear cuenta: \(error.localizedDescription)"
                }
                return
            }
            
            guard let userId = authResult?.user.uid else {
                DispatchQueue.main.async {
                    errorMessage = "Error al obtener ID de usuario."
                }
                return
            }
            
            print("✅ Usuario creado en Auth con UID: \(userId)")
            
            // PASO 2: Guardar datos adicionales en Firestore usando el UID
            let db = Firestore.firestore()
            
            let data: [String: Any] = [
                "uid": userId,  // ← IMPORTANTE: Guardamos el UID de Auth
                "username": username,
                "password": password,  // ⚠️ Nota: Guardar passwords en texto plano no es seguro
                "name": nombre,
                "last_name": apellido,
                "age": edad,
                "birthday": Timestamp(date: fechaNacimiento),
                "email": email,
                "score_sudden_death": 0,
                "score_free": 0,
                "score_data": 0,
                "score_geo": 0,
                "score_math": 0,
                "score_history": 0,
                "score_words": 0,
                "created_at": Timestamp(date: Date())
            ]
            
            // Usamos el UID como ID del documento
            db.collection("users").document(userId).setData(data) { error in
                if let error = error {
                    print("❌ Error al guardar en Firestore: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        errorMessage = "Error al guardar datos: \(error.localizedDescription)"
                    }
                    return
                }
                
                print("✅ Datos guardados en Firestore con UID: \(userId)")
                
                // ✅ Registro completo → marcar sesión y navegar
                DispatchQueue.main.async {
                    isLoggedIn = true
                    irAGameMode = true
                }
            }
        }
    }
}

#Preview {
    REGISTRARSE()
}
