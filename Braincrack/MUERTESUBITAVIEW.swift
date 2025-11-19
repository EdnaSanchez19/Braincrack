

//
//  MUERTESUBITAVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez on 09/11/25.
//

import SwiftUI
import Foundation
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - 1. Estructura de la Pregunta
struct PreguntaMS: Codable, Identifiable {
    let id: Int
    let pregunta: String
    let resp: [String]
    let respc: String
    let edad: [Int] // Lista de edades a las que aplica la pregunta
    let idioma: String
    let tema: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pregunta, resp, respc, edad, idioma, tema
    }
}

// MARK: - 2. Servicio de Carga de Preguntas Locales
final class LocalQuestionsService {
    // ESTA FUNCIÓN DEBE CARGAR LAS PREGUNTAS DESDE TU questions.json
    func cargarPreguntasDesdeJSON() -> [PreguntaMS] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            print("❌ ERROR: No se encontró questions.json. Retornando vacío.")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let preguntas = try JSONDecoder().decode([PreguntaMS].self, from: data)
            print("✅ Preguntas cargadas desde JSON: \(preguntas.count)")
            return preguntas
        } catch {
            print("❌ ERROR al decodificar JSON:", error)
            return []
        }
    }
}

// MARK: - 3. Definición de Fondos/Temas
enum FondoTemaMS {
    case DATONAUTA
    case CHISMESITOHISTORICO
    case EXACTAMANIACAA
    case LOMBRILETRAS
    case GEOGEBRA
    case SE_ACABO_EL_TIEMPO
    case DEFAULT
    
    // Función para mapear el tema de la pregunta al fondo visual
    static func fondo(para tema: String, tiempoAgotado: Bool) -> FondoTemaMS {
        if tiempoAgotado {
            return .SE_ACABO_EL_TIEMPO
        }
        switch tema {
        case "Data Nauta", "Daten Nauta", "Dati Nauta":
            return .DATONAUTA
        case "Chismes del Tiempo", "Klatsch der Zeit", "Gossip of Time":
            return .CHISMESITOHISTORICO
        case "Mente Exacta", "Exakter Verstand", "Exact Mind":
            return .EXACTAMANIACAA
        case "Letrinas", "Latrinen", "Latrines":
            return .LOMBRILETRAS
        case "GeoExplora", "GeoErkunden", "GeoExplore":
            return .GEOGEBRA
        default:
            return .DEFAULT
        }
    }
}


// MARK: - 4. ViewModel (Corregido para Firebase)
final class SuddenDeathViewModel: ObservableObject {
    
    @Published var preguntas: [PreguntaMS] = []
    @Published var preguntaActual: PreguntaMS?
    @Published var scoreActual: Int = 0
    @Published var mejorScore: Int = 0 // Usado para mostrar el récord (cargado de Firebase)
    @Published var gameOver: Bool = false
    @Published var ultimaFueCorrecta: Bool? = nil
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var tiempoRestante: Int = 10
    @Published var tiempoAgotado: Bool = false
    
    @Published var edadUsuario: Int? // La edad que se cargará de Firebase
    
    @AppStorage("selectedLanguage") private var selectedLanguageCode: String = "es"
    
    private let questionsService = LocalQuestionsService()
    private var preguntasDisponibles: [PreguntaMS] = []
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    private var idiomaUsuario: String {
        switch selectedLanguageCode.lowercased() {
        case "en": return "English"
        case "es": return "Español"
        case "de": return "Deutsch"
        default: return "Español"
        }
    }
    
    init() {
        // Asegura que FirebaseApp.configure() fue llamado antes.
        cargarDatosUsuario()
    }
    
    // MARK: - Lógica de Firebase (Cargar Edad y Mejor Score)
    func cargarDatosUsuario() {
        self.isLoading = true
        self.errorMessage = nil
        
        // 1. Verificar Autenticación.
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ USUARIO NO AUTENTICADO. Usando edad por defecto (9) y score (0).")
            self.edadUsuario = 9
            self.mejorScore = 0
            self.cargarPreguntasLocales() // Continuar con el flujo del juego
            return
        }
        
        print("✅ Usuario autenticado (\(userId)). Conectando a Firestore...")
        
        let docRef = Firestore.firestore().collection("users").document(userId)
        
        docRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ ERROR DE FIREBASE: \(error.localizedDescription)")
                self.errorMessage = "Error de conexión a la base de datos."
                self.isLoading = false
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("❌ Documento de usuario no encontrado. Asignando valores por defecto.")
                self.edadUsuario = 9
                self.mejorScore = 0
                self.cargarPreguntasLocales()
                return
            }
            
            // 2. Cargar Edad (age) - Manejo robusto de Int y Double
            if let age = data["age"] as? Int {
                self.edadUsuario = age
            } else if let ageDouble = data["age"] as? Double {
                self.edadUsuario = Int(ageDouble)
            } else {
                print("⚠️ Campo 'age' no encontrado o inválido. Usando edad por defecto (9).")
                self.edadUsuario = 9
            }
            
            // 3. Cargar Mejor Score (score_sudden_death) - Manejo robusto de Int y Double
            if let score = data["score_sudden_death"] as? Int {
                self.mejorScore = score
            } else if let scoreDouble = data["score_sudden_death"] as? Double {
                self.mejorScore = Int(scoreDouble)
            } else {
                print("⚠️ Campo 'score_sudden_death' no encontrado o inválido. Usando score por defecto (0).")
                self.mejorScore = 0
            }
            
            print("👤 Datos cargados: Edad: \(self.edadUsuario ?? 9), Mejor Score: \(self.mejorScore)")
            
            // 4. Continuar el flujo del juego
            self.cargarPreguntasLocales()
        }
    }
    
    // MARK: - Lógica para guardar el Récord en Firebase
    private func actualizarMejorScore() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ ERROR al guardar: Usuario no autenticado para guardar el récord.")
            return
        }
        
        let docRef = Firestore.firestore().collection("users").document(userId)
        
        // Solo actualizamos el campo del score si es un nuevo récord
        docRef.setData(["score_sudden_death": self.mejorScore], merge: true) { error in
            if let error = error {
                print("❌ ERROR al guardar el mejor score en Firestore: \(error.localizedDescription)")
            } else {
                print("✅ Mejor score (\(self.mejorScore)) guardado exitosamente.")
            }
        }
    }

    // MARK: - Lógica de Carga de Preguntas (El filtro usa 'edadUsuario')
    func cargarPreguntasLocales() {
        // Usa la edad cargada de Firebase (o la edad por defecto 9)
        guard let edad = self.edadUsuario else {
            self.isLoading = false
            return
        }
        
        isLoading = true
        tiempoAgotado = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let todas = self.questionsService.cargarPreguntasDesdeJSON()
            
            let filtradas = todas.filter {
                // 1. Filtro por idioma:
                let idiomaMatch =
                ($0.idioma == self.idiomaUsuario) ||
                ($0.idioma.lowercased().contains(self.selectedLanguageCode.lowercased()))
                
                // 2. Filtro por edad: Usa la edad cargada/por defecto.
                let edadMatch = $0.edad.contains(edad)
                
                return idiomaMatch && edadMatch
            }
            
            if filtradas.isEmpty {
                self.errorMessage = "No hay preguntas disponibles para el idioma \(self.idiomaUsuario) y edad \(edad)"
                self.isLoading = false
                return
            }
            
            self.preguntas = filtradas
            self.preguntasDisponibles = filtradas.shuffled()
            self.scoreActual = 0
            self.ultimaFueCorrecta = nil
            self.isLoading = false
            self.gameOver = false
            self.siguientePregunta()
        }
    }
    
    // MARK: - Lógica del Juego
    
    private func terminarJuego() {
        stopTimer()
        gameOver = true
        if scoreActual > mejorScore {
            mejorScore = scoreActual
            actualizarMejorScore() // 👈 LLAMADA CLAVE para guardar el récord
        }
    }
    
    func reiniciarPartida() {
         preguntasDisponibles = preguntas.shuffled()
         scoreActual = 0
         gameOver = false
         ultimaFueCorrecta = nil
         tiempoAgotado = false
         siguientePregunta()
    }
    
    func responder(opcion: String) {
        stopTimer()
        guard let actual = preguntaActual else { return }
              
        if opcion == actual.respc {
            ultimaFueCorrecta = true
            scoreActual += 10
            playSound("ding")
            siguientePregunta()
        } else {
            ultimaFueCorrecta = false
            playSound("error")
            tiempoAgotado = true
            terminarJuego()
        }
    }
    
    private func siguientePregunta() {
        if tiempoAgotado {
            terminarJuego()
            return
        }
              
        guard !preguntasDisponibles.isEmpty else {
            terminarJuego()
            return
        }
              
        preguntaActual = preguntasDisponibles.removeFirst()
        tiempoRestante = 10
        tiempoAgotado = false
        iniciarTimer()
    }
    
    private func iniciarTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.tiempoRestante -= 1
                if self.tiempoRestante <= 0 {
                    self.tiempoAgotado = true
                    self.stopTimer()
                    self.terminarJuego()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func playSound(_ soundName: String) {
        // Asegúrate de que los archivos 'ding.mp3' y 'error.mp3' están
        // en tu Bundle principal.
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        do {
            // Asegúrate de importar AVFoundation
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("❌ Error al reproducir el sonido: \(error.localizedDescription)")
        }
    }
}


// MARK: - 5. Vista Principal (MUERTESUBITAVIEW)
struct MUERTESUBITAVIEW: View {
    
    @StateObject private var vm = SuddenDeathViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        
        ZStack {
            fondoDinamico()
            
            VStack {
                if vm.isLoading {
                    ProgressView("Cargando datos y preguntas...")
                    
                } else if let error = vm.errorMessage {
                    VStack {
                        Text("Error").font(.title).foregroundColor(.red)
                        Text(error).multilineTextAlignment(.center)
                        Button("Reintentar") {
                            vm.cargarDatosUsuario()
                        }
                    }
                    
                } else if vm.gameOver {
                    vistaGameOver
                    
                } else {
                    vistaJuego
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: Fondo dinámico (Usa colores/texto como fallback para GIF)
    @ViewBuilder
    private func fondoDinamico() -> some View {
        let tema = vm.preguntaActual?.tema ?? "DEFAULT"
        let fondoCase = FondoTemaMS.fondo(para: tema, tiempoAgotado: vm.tiempoAgotado)
        
        ZStack {
            // Fondo de color base
            Color.white.ignoresSafeArea()
            
            // Reemplazo de AnimatedImage por una indicación de texto sobre un color
            Group {
                switch fondoCase {
                case .DATONAUTA:
                    Color.purple.opacity(0.3)
                case .CHISMESITOHISTORICO:
                    Color.yellow.opacity(0.3)
                case .EXACTAMANIACAA:
                    Color.blue.opacity(0.3)
                case .LOMBRILETRAS:
                    Color.green.opacity(0.3)
                case .GEOGEBRA:
                    Color.orange.opacity(0.3)
                case .SE_ACABO_EL_TIEMPO:
                    Color.red.opacity(0.5)
                case .DEFAULT:
                    Color.gray.opacity(0.1)
                }
            }
            .ignoresSafeArea()
            
            // Texto de advertencia (Solo en modo Previsualización sin la librería de GIF)
            if vm.isLoading == false {
                 Text("⚠️ Fondo de GIF NO cargado\n(Falta AnimatedImage)")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))
                    .padding()
                    .background(.white.opacity(0.8))
                    .cornerRadius(8)
            }
        }
    }
    
    private var vistaJuego: some View {
        VStack(spacing: 15) {
            if let pregunta = vm.preguntaActual {
                Text(pregunta.pregunta)
                    .font(.headline)
                    .frame(maxWidth: 300, maxHeight: 150)
                    .multilineTextAlignment(.center)
                    .padding(.top,100)
            }
            
            Text("Puntaje actual: \(vm.scoreActual)")
                .padding(.top,80)
            Text("⏱: \(vm.tiempoRestante)")
                .font(.subheadline)
                .foregroundColor(vm.tiempoRestante <= 3 ? .red : .primary)
                .padding(.top)
            
            VStack() {
                if let pregunta = vm.preguntaActual {
                    ForEach(pregunta.resp, id: \.self) { opcion in
                        Button(action: { vm.responder(opcion: opcion) }) {
                            Text(opcion)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 350, height: 70)
                                .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                                .cornerRadius(18)
                                .shadow(radius: 4)
                        }
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }
    
    private var vistaGameOver: some View {
        VStack(spacing: 24) {
            Text(LocalizedStringKey("Fin del Juego"))
                .font(.custom("GlacialIndifference-Bold", size: 40))
                .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                .bold()
                .padding(.top,100)
            
            VStack(spacing: 10) {
                Text(LocalizedStringKey("Tu puntaje"))
                    .font(.title3)
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                
                Text("\(vm.scoreActual)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                
                Text(LocalizedStringKey("Récord"))
                    .font(.title2)
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                Text(" \(vm.mejorScore)")
            }
            .padding(.top,200)
        
            Button(LocalizedStringResource("Volver a intentar")) {
                vm.reiniciarPartida()
            }
            .padding()
            .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
            .foregroundStyle(Color.white)
            .cornerRadius(12)
                
            Button(LocalizedStringResource("Menu")) {
                dismiss()
            }
            .padding()
            .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
            .foregroundStyle(Color.white)
            .cornerRadius(12)
        }
    }
}


#Preview {
    MUERTESUBITAVIEW()
}
