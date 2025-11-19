
// DATONAUTAVIEW.swift
// Braincrack
//
// Created by Edna Sanchez on 09/11/25.
//


import SwiftUI
import Foundation
import AVFoundation
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI

// MARK: - 0. Gestor de Sonidos
final class Sonidos {
    private var player: AVAudioPlayer?

    private func play(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("❌ ERROR: No se encontró el archivo de sonido: \(filename).mp3")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch let error {
            print("❌ ERROR al reproducir el sonido \(filename):", error.localizedDescription)
        }
    }
    
    func playDing() {
        play(filename: "ding")
    }
    
    func playError() {
        play(filename: "error")
    }
}

// MARK: - 1. Modelo de Pregunta
struct PreguntaDN: Codable, Identifiable {
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

// MARK: - 2. Servicio de Carga Local
final class DataNautaQuestionsService {
    func cargarPreguntasDesdeJSON(idioma: String) -> [PreguntaDN] {
        var fileName: String
        
        switch idioma.lowercased() {
        case "español":
            fileName = "preguntas-español"
        case "english":
            fileName = "preguntas-ingles"
        case "deutsch":
            fileName = "preguntas-aleman"
        default:
            fileName = "preguntas-español"
        }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("❌ ERROR: No se encontró \(fileName).json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let preguntas = try JSONDecoder().decode([PreguntaDN].self, from: data)
            print("✅ Preguntas cargadas: \(preguntas.count) para el idioma \(idioma)")
            return preguntas
        } catch {
            print("❌ ERROR al decodificar JSON:", error)
            return []
        }
    }
}

// MARK: - 3. Fondos para Data Nauta
enum FondoDataNauta {
    case DATANAUTA_NORMAL
    case GAME_OVER
    case DEFAULT
    
    static func fondo(para tema: String, gameOver: Bool) -> FondoDataNauta {
        if gameOver {
            return .GAME_OVER
        }
        
        switch tema {
        case "Data Nauta", "Daten Nauta", "Dati Nauta":
            return .DATANAUTA_NORMAL
        default:
            return .DEFAULT
        }
    }
}

// MARK: - 4. ViewModel
final class DataNautaViewModel: ObservableObject {
    
    @Published var preguntas: [PreguntaDN] = []
    @Published var preguntaActual: PreguntaDN?
    @Published var scoreActual: Int = 0
    @Published var mejorScore: Int = 0
    @Published var gameOver: Bool = false
    @Published var ultimaFueCorrecta: Bool? = nil
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var edadUsuario: Int?
    
    @AppStorage("selectedLanguage") private var selectedLanguageCode: String = "es"
    
    private let questionsService = DataNautaQuestionsService()
    private let soundManager = Sonidos()
    private var preguntasDisponibles: [PreguntaDN] = []
    
    private var idiomaUsuario: String {
        switch selectedLanguageCode.lowercased() {
        case "en": return "English"
        case "es": return "Español"
        case "de": return "Deutsch"
        default: return "Español"
        }
    }
    
    init() {
        cargarDatosUsuario()
    }
    
    // MARK: - Firebase
    func cargarDatosUsuario() {
        self.isLoading = true
        self.errorMessage = nil
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ Usuario no autenticado. Usando valores por defecto.")
            self.edadUsuario = 9
            self.mejorScore = 0
            self.cargarPreguntasDataNauta()
            return
        }
        
        print("✅ Usuario autenticado (\(userId))")
        
        let docRef = Firestore.firestore().collection("users").document(userId)
        
        docRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ ERROR DE FIREBASE: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Error de conexión a la base de datos."
                    self.isLoading = false
                }
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("❌ Documento de usuario no encontrado.")
                DispatchQueue.main.async {
                    self.edadUsuario = 9
                    self.mejorScore = 0
                    self.cargarPreguntasDataNauta()
                }
                return
            }
            
            // Cargar Edad
            if let age = data["age"] as? Int {
                self.edadUsuario = age
            } else if let ageDouble = data["age"] as? Double {
                self.edadUsuario = Int(ageDouble)
            } else {
                self.edadUsuario = 9
            }
            
            // Cargar Score de Data Nauta
            if let score = data["score_data"] as? Int {
                self.mejorScore = score
            } else if let scoreDouble = data["score_data"] as? Double {
                self.mejorScore = Int(scoreDouble)
            } else {
                self.mejorScore = 0
            }
            
            print("👤 Edad: \(self.edadUsuario ?? 9), Mejor Score Data Nauta: \(self.mejorScore)")
            
            DispatchQueue.main.async {
                self.cargarPreguntasDataNauta()
            }
        }
    }
    
    private func actualizarMejorScore() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ ERROR: Usuario no autenticado para guardar.")
            return
        }
        
        let docRef = Firestore.firestore().collection("users").document(userId)
        
        docRef.setData(["score_data": self.mejorScore], merge: true) { error in
            if let error = error {
                print("❌ ERROR al guardar score: \(error.localizedDescription)")
            } else {
                print("✅ Score de Data Nauta guardado: \(self.mejorScore)")
            }
        }
    }
    
    // MARK: - Cargar Preguntas
    func cargarPreguntasDataNauta() {
        guard let edad = self.edadUsuario else {
            self.isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let todas = self.questionsService.cargarPreguntasDesdeJSON(idioma: self.idiomaUsuario)
            
            // Filtro: Solo Data Nauta y sus variantes
            let filtradas = todas.filter { pregunta in
                let idiomaPregunta = pregunta.idioma.lowercased()
                
                let idiomaMatch =
                    (idiomaPregunta.contains("español") || idiomaPregunta.contains("es")) && self.idiomaUsuario == "Español" ||
                    (idiomaPregunta.contains("english") || idiomaPregunta.contains("en")) && self.idiomaUsuario == "English" ||
                    (idiomaPregunta.contains("deutsch") || idiomaPregunta.contains("de")) && self.idiomaUsuario == "Deutsch"
                
                let edadMatch = pregunta.edad.contains(edad)
                
                let temaMatch = pregunta.tema == "Data Nauta" ||
                               pregunta.tema == "Daten Nauta" ||
                               pregunta.tema == "Dati Nauta"
                
                return idiomaMatch && edadMatch && temaMatch
            }
            
            if filtradas.isEmpty {
                self.errorMessage = "No hay preguntas de Data Nauta disponibles para idioma \(self.idiomaUsuario) y edad \(edad)"
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
    func reiniciarPartida() {
        preguntasDisponibles = preguntas.shuffled()
        scoreActual = 0
        gameOver = false
        ultimaFueCorrecta = nil
        siguientePregunta()
    }
    
    func responder(opcion: String) {
        guard let actual = preguntaActual else { return }
        
        if opcion == actual.respc {
            ultimaFueCorrecta = true
            scoreActual += 10
            soundManager.playDing()
            siguientePregunta()
        } else {
            ultimaFueCorrecta = false
            soundManager.playError()
            terminarJuego()
        }
    }
    
    private func terminarJuego() {
        gameOver = true
        if scoreActual > mejorScore {
            mejorScore = scoreActual
            actualizarMejorScore()
        }
    }
    
    private func siguientePregunta() {
        guard !preguntasDisponibles.isEmpty else {
            terminarJuego()
            return
        }
        
        preguntaActual = preguntasDisponibles.removeFirst()
    }
}

// MARK: - 5. Vista Principal
struct DATONAUTAVIEW: View {
    
    @StateObject private var vm = DataNautaViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            fondoDinamico()
            
            VStack {
                if vm.isLoading {
                    ProgressView("Cargando preguntas de Data Nauta...")
                        .tint(.white)
                        .foregroundColor(.white)
                    
                } else if let error = vm.errorMessage {
                    VStack(spacing: 20) {
                        Text("Error")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Reintentar") {
                            vm.cargarDatosUsuario()
                        }
                        .padding()
                        .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                        .foregroundColor(.white)
                        .cornerRadius(12)
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
    
    // MARK: Fondo dinámico
    @ViewBuilder
    private func fondoDinamico() -> some View {
        let tema = vm.preguntaActual?.tema ?? ""
        let fondoCase = FondoDataNauta.fondo(para: tema, gameOver: vm.gameOver)
        
        ZStack {
            Color.white.ignoresSafeArea()
            
            switch fondoCase {
            case .DATANAUTA_NORMAL:
                if let url = GIFS.GIFDATINAUTA() {
                    AnimatedImage(url: url)
                        .resizable()
                        .customLoopCount(0)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                } else {
                    Color.blue.ignoresSafeArea()
                }
                
            case .GAME_OVER:
                if let url = GIFS.GIFSEACABOELTIEMPO() {
                    AnimatedImage(url: url)
                        .resizable()
                        .customLoopCount(0)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea()
                }
                
            case .DEFAULT:
                Color.white.ignoresSafeArea()
            }
        }
    }
    
    private var vistaJuego: some View {
        VStack {
            // Pregunta
            if let pregunta = vm.preguntaActual {
                Text(pregunta.pregunta)
                    .font(.custom("GlacialIndifference-Bold", size: 23))
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .frame(maxWidth: 350, maxHeight: 200)
                    .multilineTextAlignment(.center)
                    .padding(.trailing,10)
                    .padding(.top, 50)
            }
            
            // Puntaje
            Text("Puntaje: \(vm.scoreActual)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                .padding()
            
            // Opciones de respuesta
            VStack(spacing: 15) {
                if let pregunta = vm.preguntaActual {
                    ForEach(pregunta.resp, id: \.self) { opcion in
                        Button(action: { vm.responder(opcion: opcion) }) {
                            Text(opcion)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: 350)
                                .frame(height: 70)
                                .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                                .cornerRadius(18)
                                .shadow(radius: 4)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 50)
        }
    }
    
    private var vistaGameOver: some View {
        VStack(spacing: 24) {
            Text(LocalizedStringKey("Fin del Juego"))
                .font(.custom("GlacialIndifference-Bold", size: 40))
                .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                .bold()
                .padding(.top, 100)
            
            VStack(spacing: 10) {
                Text(LocalizedStringKey("Tu puntaje"))
                    .font(.custom("GlacialIndifference-Bold", size: 20))
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                
                Text("\(vm.scoreActual)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                
                Text(LocalizedStringKey("Récord"))
                    .font(.custom("GlacialIndifference-Bold", size: 20))
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                
                Text("\(vm.mejorScore)")
                    .font(.title)
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
            }
            .padding(.top, 200)
            
            // Botón "Volver a jugar"
            Button(action: {
                vm.reiniciarPartida()
            }) {
                Text(LocalizedStringKey("Volver a jugar"))
                    .font(.custom("GlacialIndifference-Bold", size: 20))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .cornerRadius(12)
            }
            
            // Botón "Menú"
            Button(action: {
                dismiss()
            }) {
                Text(LocalizedStringKey("Menú"))
                    .font(.custom("GlacialIndifference-Bold", size: 20))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

#Preview {
    DATONAUTAVIEW()
}
