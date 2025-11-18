

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


// MARK: - 1. Modelo de Pregunta

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
    
    // MARK: - 2. Servicio de Carga Local
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
    
    // MARK: - 3. Fondos según tema
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
    
    // MARK: - 4. ViewModel
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
        
        private let questionsService = LocalQuestionsService()
        private let edadUsuario = 9
        private var preguntasDisponibles: [PreguntaMS] = []
        private var timer: Timer?
        
        private var idiomaUsuario: String {
            let code = Locale.current.languageCode?.lowercased() ?? "es"
            switch code {
            case "en": return "English"
            case "es": return "Español"
            case "de": return "Deutsch"
            default:   return "Español"
            }
        }
        
        private var audioPlayer: AVAudioPlayer?
        
        init() {
            cargarPreguntasLocales()
        }
        
        func cargarPreguntasLocales() {
            isLoading = true
            tiempoAgotado = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let todas = self.questionsService.cargarPreguntasDesdeJSON()
                
                let filtradas = todas.filter {
                    let idiomaPregunta = $0.idioma.lowercased()
                    
                    let idiomaMatch =
                    (idiomaPregunta.contains("es") || idiomaPregunta.contains("Español")) && self.idiomaUsuario == "Español" ||
                    (idiomaPregunta.contains("en") || idiomaPregunta.contains("English")) && self.idiomaUsuario == "English" ||
                    (idiomaPregunta.contains("de") || idiomaPregunta.contains("Deutsch")) && self.idiomaUsuario == "Deutsch"
                    
                    return idiomaMatch && $0.edad.contains(self.edadUsuario)
                }
                
                if filtradas.isEmpty {
                    self.errorMessage = "No hay preguntas disponibles"
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
                tiempoAgotado = true  // Cambia el fondo cuando se responde mal
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
            playSound("timer")
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
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                DispatchQueue.main.async {
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
        
        // Reproduce los sonidos de respuesta correcta o incorrecta
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
    
    // MARK: - 5. Vista Principal
    struct MUERTESUBITAVIEW: View {
        
        @StateObject private var vm = SuddenDeathViewModel()
        
        var body: some View {
            
            ZStack {
                fondoDinamico()
                
                VStack {
                    if vm.isLoading {
                        ProgressView("Cargando preguntas...")
                        
                    } else if let error = vm.errorMessage {
                        Text("Error").font(.title)
                        Text(error)
                        Button("Reintentar") {
                            vm.cargarPreguntasLocales()
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
            }.padding(.bottom, 100)
        }
        
        private var vistaGameOver: some View {
            VStack(spacing: 24) {
                Text("Fin de la partida")
                    .font(.custom("GlacialIndifference-Bold", size: 40))
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .bold()
                    .padding(.bottom,250)
                Text("Score:" + "\(vm.scoreActual)")
                Text("Mejor récord: \(vm.mejorScore)")
                
                Button("Volver a intentar") {
                    vm.reiniciarPartida()
                }
                .padding()
                .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                .foregroundStyle(Color.white)
                .cornerRadius(12)
                
                Button("Menu") {
                    
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

