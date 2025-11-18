

//
//  MUERTESUBITAVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez on 09/11/25.
//

import SwiftUI
import Foundation
import SDWebImageSwiftUI
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - 1. Modelo de Pregunta (Sin Cambios)
struct PreguntaMS: Codable, Identifiable {
    let id: Int
    let pregunta: String
    let resp: [String]
    let respc: String
    let edad: [Int]
    let idioma: String
    let tema: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pregunta, resp, respc, edad, idioma, tema
    }
}
    
// MARK: - 2. Servicio de Carga Local (Sin Cambios)
final class LocalQuestionsService {
    func cargarPreguntasDesdeJSON() -> [PreguntaMS] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            print("❌ ERROR: No se encontró questions.json")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let preguntas = try JSONDecoder().decode([PreguntaMS].self, from: data)
            print("✅ Preguntas cargadas: \(preguntas.count)")
            return preguntas
        } catch {
            print("❌ ERROR al decodificar JSON:", error)
            return []
        }
    }
}
    
// MARK: - 3. Fondos según tema (Sin Cambios)
enum FondoTemaMS {
    case DATONAUTA
    case CHISMESITOHISTORICO
    case EXACTAMANIACAA
    case LOMBRILETRAS
    case GEOGEBRA
    case SE_ACABO_EL_TIEMPO
    case DEFAULT
    
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
    
// MARK: - 4. ViewModel (Conexión Firebase y @AppStorage)
final class SuddenDeathViewModel: ObservableObject {
        
    @Published var preguntas: [PreguntaMS] = []
    @Published var preguntaActual: PreguntaMS?
    @Published var scoreActual: Int = 0
    @Published var mejorScore: Int = 0
    @Published var gameOver: Bool = false
    @Published var ultimaFueCorrecta: Bool? = nil
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var tiempoRestante: Int = 10
    @Published var tiempoAgotado: Bool = false
    
    @Published var edadUsuario: Int?
    
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
        default:   return "Español"
        }
    }
    
    init() {
        cargarDatosUsuario()
    }
    
    // MARK: - Lógica de Firebase (Cargar Edad)
    func cargarDatosUsuario() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ ERROR: No hay usuario autenticado. Usando edad por defecto (9).")
            self.edadUsuario = 9
            self.cargarPreguntasLocales()
            return
        }
        
        let docRef = Firestore.firestore().collection("users").document(userId)
        
        docRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                if let age = document.data()?["age"] as? Int {
                    self.edadUsuario = age
                } else if let ageDouble = document.data()?["age"] as? Double {
                    self.edadUsuario = Int(ageDouble)
                } else {
                    print("⚠️ El campo 'age' no se encontró o no es un número. Usando edad por defecto (9).")
                    self.edadUsuario = 9
                }
            } else {
                print("❌ Documento de usuario no encontrado. Usando edad por defecto (9).")
                self.edadUsuario = 9
            }
            self.cargarPreguntasLocales()
        }
    }
    
    // MARK: - Lógica de Carga de Preguntas (Conexión Edad/Idioma)
    func cargarPreguntasLocales() {
        guard let edad = self.edadUsuario else {
            self.isLoading = true
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
                
                // 2. Filtro por edad:
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
            self.mejorScore = 0
            self.ultimaFueCorrecta = nil
            self.isLoading = false
            self.gameOver = false
            self.siguientePregunta()
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
        
    private func terminarJuego() {
        stopTimer()
        gameOver = true
        if scoreActual > mejorScore {
            mejorScore = scoreActual
        }
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
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        do {
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
    @Environment(\.dismiss) var dismiss // Para volver a TEMASVIEW

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
        
    // MARK: Fondo dinámico según tema o tiempo agotado
    @ViewBuilder
    private func fondoDinamico() -> some View {
        let tema = vm.preguntaActual?.tema ?? ""
        let fondoCase = FondoTemaMS.fondo(para: tema, tiempoAgotado: vm.tiempoAgotado)
            
        switch fondoCase {
        case .DATONAUTA:
            AnimatedImage(url: GIFS.GIFDATINAUTA()).resizable().ignoresSafeArea()
        case .CHISMESITOHISTORICO:
            AnimatedImage(url: GIFS.GIFCHISME()).resizable().ignoresSafeArea()
        case .EXACTAMANIACAA:
            AnimatedImage(url: GIFS.GIFMENTEEXACTA()).resizable().ignoresSafeArea()
        case .LOMBRILETRAS:
            AnimatedImage(url: GIFS.GIFLETRINAS()).resizable().ignoresSafeArea()
        case .GEOGEBRA:
            AnimatedImage(url: GIFS.GIFGEOEXPLORA()).resizable().ignoresSafeArea()
        case .SE_ACABO_EL_TIEMPO:
            AnimatedImage(url: GIFS.GIFSEACABOELTIEMPO()).resizable().ignoresSafeArea()
        case .DEFAULT:
            Color.white.ignoresSafeArea()
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
                .foregroundColor(vm.tiempoRestante <= 3 ? .red : .black)
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

