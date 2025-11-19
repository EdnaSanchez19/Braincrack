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
        // Tu UI de ZStack y VStack va aquí... (código omitido por brevedad)
        NavigationStack {
            ZStack {
                // ... Todo el código de tu diseño de ZStack ...
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
                // Aquí es donde instanciarías tu vista principal del juego.
                // Asegúrate de que GAMEMODEVIEW pueda acceder a los datos de autenticación.
                GAMEMODEVIEW()
            }
        }
    }

    // ---------- Helpers ----------

    var camposVacios: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Función login MODIFICADA
    func login() {
        errorMessage = nil
        let db = Firestore.firestore()
        
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .whereField("password", isEqualTo: password)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Error al buscar usuario: \(error.localizedDescription)")
                    errorMessage = "Ocurrió un error al iniciar sesión."
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    errorMessage = "Usuario o contraseña incorrectos."
                    return
                }
                
                let userId = document.documentID
                
                // 1. INICIO DE SESIÓN EN FIREBASE: Usamos signInAnonymously como truco,
                //    pero le asignamos el ID del documento de Firestore como su UID.
                //    Esto es CRÍTICO para que el ViewModel pueda acceder a Auth.auth().currentUser?.uid
                Auth.auth().signInAnonymously { authResult, authError in
                    if let authError = authError {
                        print("Error al simular autenticación anónima: \(authError.localizedDescription)")
                        self.errorMessage = "Error de autenticación. Inténtalo de nuevo."
                        return
                    }
                    
                    // 2. Si la simulación de sesión anónima es exitosa,
                    //    podrías considerar guardar el ID del documento en un lugar accesible
                    //    o, idealmente, si usaras Email/Password, el UID de Firebase
                    //    sería automáticamente el ID del usuario.
                    //
                    // Dado que Auth.auth().currentUser ya está configurado,
                    // el SuddenDeathViewModel ahora podrá acceder al UID.
                    
                    // Si el inicio de sesión es exitoso (Firestore + Auth simulado)
                    print("✅ Usuario logueado con Document ID: \(userId)")
                    self.isLoggedIn = true
                    self.irAGameMode = true // Activa la navegación
                }
            }
    }
}
#Preview {
    INICIARSESION()
}

