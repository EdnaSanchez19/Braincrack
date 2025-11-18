
// DATONAUTAVIEW.swift
// Braincrack
//
// Created by Edna Sanchez on 09/11/25.
//
// DATONAUTAVIEW.swift
// Braincrack
//
// Created by Edna Sanchez on 09/11/25.
//

import SwiftUI
import Foundation
import SDWebImageSwiftUI // Necesario para mostrar GIFs
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - 0. Gestor de Sonidos
final class Sonidos {
    
    // Necesario para manejar la reproducción de audio
    private var player: AVAudioPlayer?

    // Función genérica para cargar y reproducir audio desde un archivo
    private func play(filename: String) {
        // Busca el archivo en el bundle principal de la app
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("❌ ERROR: No se encontró el archivo de sonido: \(filename).mp3")
            return
        }

        do {
            // Inicializa y prepara la reproducción
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch let error {
            print("❌ ERROR al reproducir el sonido \(filename):", error.localizedDescription)
        }
    }
    
    // Métodos públicos para los sonidos solicitados
    func playDing() {
        // Asegúrate de que el nombre del archivo coincida con el nombre subido (ding.mp3)
        play(filename: "ding")
    }
    
    func playError() {
        // Asegúrate de que el nombre del archivo coincida con el nombre subido (error.mp3)
        play(filename: "error")
    }
}

// MARK: - 1. Modelo de Pregunta
struct Pregunta1: Codable, Identifiable {
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
final class LocalQuestionsService1 {
    
    func cargarPreguntasDesdeJSON(idioma: String) -> [Pregunta1] {
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
            let preguntas = try JSONDecoder().decode([Pregunta1].self, from: data)
            print("✅ Preguntas cargadas: \(preguntas.count) para el idioma \(idioma)")
            return preguntas
        } catch {
            print("❌ ERROR al decodificar JSON:", error)
            return []
        }
    }
}

// MARK: - 3. Fondos según tema
enum FondoTema1 {
    case DATONAUTA
    case GAMEOVER // Nuevo caso para el fondo de fin de juego
    case DEFAULT
    
    static func fondo(para tema: String) -> FondoTema1 {
        switch tema {
        case "Data Nauta", "Daten Nauta", "Dati Nauta":
            return .DATONAUTA
        default:
            return .DEFAULT
        }
    }
}

// MARK: - 4. ViewModel (Corregido con lógica de Sonido)
final class DataNautaViewModel: ObservableObject {
    
    @Published var preguntas: [Pregunta1] = []
    @Published var preguntaActual: Pregunta1?
    @Published var scoreActual: Int = 0
    @Published var mejorScore: Int = 0
    @Published var gameOver: Bool = false
    @Published var ultimaFueCorrecta: Bool? = nil
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    private let questionsService = LocalQuestionsService1()
    private let soundManager = Sonidos() // Gestor de sonidos
    private let edadUsuario = 9
    private var preguntasDisponibles: [Pregunta1] = []
    
    private var idiomaUsuario: String {
        let code = Locale.current.language.languageCode?.identifier.lowercased() ?? "es"
        switch code {
        case "en": return "English"
        case "es": return "Español"
        case "de": return "Deutsch"
        default:   return "Español"
        }
    }
    
    init() {
        cargarMejorScore()
        cargarPreguntasLocales()
    }
    
    func cargarPreguntasLocales() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let todas = self.questionsService.cargarPreguntasDesdeJSON(idioma: self.idiomaUsuario)
            
            // Filtrar por idioma y edad
            let filtradas = todas.filter { pregunta in
                let idiomaPregunta = pregunta.idioma.lowercased()
                
                let idiomaMatch =
                    (idiomaPregunta.contains("Español") || idiomaPregunta.contains("es")) && self.idiomaUsuario == "Español" ||
                    (idiomaPregunta.contains("English") || idiomaPregunta.contains("en")) && self.idiomaUsuario == "English" ||
                    (idiomaPregunta.contains("Deutsch") || idiomaPregunta.contains("de")) && self.idiomaUsuario == "Deutsch"
                
                let temaMatch = pregunta.tema == "Data Nauta" ||
                                pregunta.tema == "Daten Nauta" ||
                                pregunta.tema == "Dati Nauta"
                
                return idiomaMatch && pregunta.edad.contains(self.edadUsuario) && temaMatch
            }
            
            if filtradas.isEmpty {
                self.errorMessage = "No hay preguntas disponibles para \(self.idiomaUsuario) y edad \(self.edadUsuario)"
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
    
    func reiniciarPartida() {
        preguntasDisponibles = preguntas.shuffled()
        scoreActual = 0
        gameOver = false
        ultimaFueCorrecta = nil
        siguientePregunta()
    }
    
    // Lógica de respuesta con manejo de sonido
    func responder(opcion: String) {
        guard let actual = preguntaActual else { return }
        
        if opcion == actual.respc {
            ultimaFueCorrecta = true
            scoreActual += 10
            soundManager.playDing() // 🔔 Sonido ding (Correcta)
            siguientePregunta()
        } else {
            ultimaFueCorrecta = false
            soundManager.playError() // ❌ Sonido error (Incorrecta)
            if scoreActual > mejorScore {
                mejorScore = scoreActual
                guardarMejorScore()
            }
            gameOver = true
        }
    }
    
    private func siguientePregunta() {
        guard !preguntasDisponibles.isEmpty else {
            if scoreActual > mejorScore {
                mejorScore = scoreActual
                guardarMejorScore()
            }
            gameOver = true
            return
        }
        
        preguntaActual = preguntasDisponibles.removeFirst()
    }
    
    private func guardarMejorScore() {
        UserDefaults.standard.set(mejorScore, forKey: "mejorScoreDataNauta")
    }
    
    private func cargarMejorScore() {
        mejorScore = UserDefaults.standard.integer(forKey: "mejorScoreDataNauta")
    }
}

// MARK: - 5. Vista Principal (Modificada para Game Over y Botón Menú)
struct DATONAUTAVIEW: View {
    
    @StateObject private var vm = DataNautaViewModel()
    @Environment(\.dismiss) var dismiss // Para cerrar la vista y volver al menú anterior

    var body: some View {
        ZStack {
            fondoDinamico()
            
            VStack {
                if vm.isLoading {
                    ProgressView("Cargando preguntas...")
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
                            vm.cargarPreguntasLocales()
                        }
                        .padding()
                        .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding()
                } else if vm.gameOver {
                    vistaGameOver
                } else {
                    vistaJuego
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: Fondo dinámico según estado
    @ViewBuilder
    private func fondoDinamico() -> some View {
        if vm.gameOver {
            // Fondo para Game Over (GIFSEACABOELTIEMPO)
            if let url = GIFS.GIFSEACABOELTIEMPO() {
                AnimatedImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea() // Fondo de fallback
            }
        } else {
            // Fondo de juego normal (DATONAUTA o DEFAULT)
            let tema = vm.preguntaActual?.tema ?? ""
            let fondoCase = FondoTema1.fondo(para: tema)
            
            switch fondoCase {
            case .DATONAUTA:
                if let url = GIFS.GIFDATINAUTA() {
                    AnimatedImage(url: url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                } else {
                    Color.blue.ignoresSafeArea()
                }
            case .DEFAULT:
                Color.white.ignoresSafeArea()
            case .GAMEOVER: // Este caso no se usa aquí gracias al if/else inicial
                Color.black.ignoresSafeArea()
            }
        }
    }

    private var vistaJuego: some View {
        VStack() {
            // Pregunta
            if let pregunta = vm.preguntaActual {
                Text(pregunta.pregunta)
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: 350,maxHeight: 200)
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.top,80)
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
         
            
            // Botón "Volver a jugar"
            Button(action: {
                vm.reiniciarPartida()
            }) {
                Text("Volver a jugar")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .cornerRadius(12)
            }
            
            // Botón "Menú" (NUEVO)
            Button(action: {
                dismiss()
            }) {
                Text("Menú")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .cornerRadius(12)
            }
        }
        .padding()
        .padding()
    }
}

#Preview {
    DATONAUTAVIEW()
}
