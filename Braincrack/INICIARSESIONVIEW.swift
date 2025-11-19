//
//  INICIARSESIONVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 06/10/25.
//


import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

extension INICIARSESION {
    var iniciarsesionview: some View {
        NavigationStack {
            ZStack {
                Image("REGISTRARSE")
                    .resizable()
                    .ignoresSafeArea()
                
                Text(LocalizedStringKey("INICIAR SESIÓN"))
                    .font(.custom("GlacialIndifference-Bold", size: 40))
                    .foregroundColor(Color(red: 1.0, green: 0.5216, blue: 0.5216))
                    .padding(.bottom, 555)

                Text(LocalizedStringKey("INICIAR SESIÓN"))
                    .font(.custom("GlacialIndifference-Bold", size: 40))
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .padding(.bottom, 550)
                
                VStack(spacing: 5) {
                    
                    // ---------- USUARIO ----------
                    ZStack {
                        Text(LocalizedStringKey("Usuario"))
                            .font(.custom("GlacialIndifference-Bold", size: 40))
                            .foregroundColor(Color(red: 1.0, green: 0.5216, blue: 0.5216))
                            .frame(width: 200)
                            .padding(.bottom, 15)
                            .padding(.trailing, 200)
                            
                        Text(LocalizedStringKey("Usuario"))
                            .font(.custom("GlacialIndifference-Bold", size: 40))
                            .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                            .frame(width: 200)
                            .padding(.bottom, 10)
                            .padding(.trailing, 200)
                    }

                    TextField(
                        LocalizedStringKey("Escriba su nombre de usuario"),
                        text: $username
                    )
                    .font(.custom("GlacialIndifference-Regular", size: 30))
                    .padding(8)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .frame(width: 350)
                    .cornerRadius(20)
                    .padding(.trailing, 35)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                    // ---------- CONTRASEÑA ----------
                    ZStack {
                        Text(LocalizedStringKey("Contraseña"))
                            .font(.custom("GlacialIndifference-Bold", size: 40))
                            .foregroundColor(Color(red: 1.0, green: 0.5216, blue: 0.5216))
                            .frame(width: 200)
                            .padding(.bottom, 15)
                            .padding(.trailing, 200)

                        Text(LocalizedStringKey("Contraseña"))
                            .font(.custom("GlacialIndifference-Bold", size: 40))
                            .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                            .frame(width: 200)
                            .padding(.bottom, 10)
                            .padding(.trailing, 200)
                    }

                    SecureField(
                        LocalizedStringKey("Escriba su contraseña"),
                        text: $password
                    )
                    .font(.custom("GlacialIndifference-Regular", size: 30))
                    .padding(8)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .frame(width: 350)
                    .cornerRadius(20)
                    .padding(.trailing, 35)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                    // ---------- ERROR ----------
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 8)
                            .multilineTextAlignment(.center)
                    }

                    // ---------- BOTÓN ENTRAR ----------
                    Button(action: {
                        login()
                    }) {
                        Rectangle()
                            .frame(width: 200, height: 80)
                            .foregroundColor(
                                camposVacios ?
                                Color.gray.opacity(0.6) :
                                Color(red: 0.187, green: 0.003, blue: 0.381)
                            )
                            .cornerRadius(50)
                            .overlay(
                                Text(LocalizedStringKey("ENTRAR"))
                                    .font(.custom("GlacialIndifference-Bold", size: 35))
                                    .foregroundColor(Color(red: 0.757, green: 0.708, blue: 0.93))
                            )
                            .padding(.top, 50)
                            .padding(.trailing, 170)
                    }
                    .disabled(camposVacios)

                }
            }
            .navigationDestination(isPresented: $irAGameMode) {
                GAMEMODEVIEW()
            }
        }
    }

    // ---------- Helpers ----------

    var camposVacios: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // FUNCIÓN LOGIN SIMPLIFICADA Y CORREGIDA
    func login() {
        errorMessage = nil
        let db = Firestore.firestore()
        
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // PASO 1: Buscar el usuario en Firestore por username
        db.collection("users")
            .whereField("username", isEqualTo: cleanUsername)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Error al buscar usuario: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        errorMessage = "Ocurrió un error al iniciar sesión."
                    }
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("❌ Usuario no encontrado")
                    DispatchQueue.main.async {
                        errorMessage = "Usuario o contraseña incorrectos."
                    }
                    return
                }
                
                let storedPassword = document.data()["password"] as? String ?? ""
                let userEmail = document.data()["email"] as? String ?? ""
                
                // Verificar contraseña
                guard storedPassword == cleanPassword else {
                    print("❌ Contraseña incorrecta")
                    DispatchQueue.main.async {
                        errorMessage = "Usuario o contraseña incorrectos."
                    }
                    return
                }
                
                guard !userEmail.isEmpty else {
                    print("❌ Email no encontrado")
                    DispatchQueue.main.async {
                        errorMessage = "Error de configuración de usuario."
                    }
                    return
                }
                
                // PASO 2: Autenticar con Firebase Auth
                Auth.auth().signIn(withEmail: userEmail, password: cleanPassword) { authResult, authError in
                    if let authError = authError {
                        print("❌ Error de autenticación: \(authError.localizedDescription)")
                        DispatchQueue.main.async {
                            errorMessage = "Error al iniciar sesión. Verifica tus credenciales."
                        }
                        return
                    }
                    
                    // ✅ Login exitoso
                    DispatchQueue.main.async {
                        print("✅ Login exitoso")
                        print("✅ UID: \(Auth.auth().currentUser?.uid ?? "N/A")")
                        isLoggedIn = true
                        irAGameMode = true
                    }
                }
            }
    }
}

#Preview {
    INICIARSESION()
}
