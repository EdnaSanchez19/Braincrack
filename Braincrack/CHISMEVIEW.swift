//
//  CHISMEVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 13/11/25.
//


import SwiftUI
import Foundation
import AVFoundation
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI

//audio
final class Sonidos2 {
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

// Música de fondo
final class MusicaChisme: ObservableObject {
    private var player: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 0.5
    
    func iniciarMusica() {
        guard let url = Bundle.main.url(forResource: "chisme", withExtension: "mp3") else {
            print("❌ ERROR: No se encontró el archivo chisme.mp3")
            return
        }
        
        do {
            // Configurar sesión de audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Loop infinito
            player?.volume = volume
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            print("✅ Música iniciada correctamente")
        } catch let error {
            print("❌ ERROR al reproducir música de fondo:", error.localizedDescription)
        }
    }
    
    func pausar() {
        player?.pause()
        isPlaying = false
    }
    
    func reanudar() {
        player?.play()
        isPlaying = true
    }
    
    func detener() {
        player?.stop()
        isPlaying = false
    }
    
    func cambiarVolumen(_ nuevoVolumen: Float) {
        volume = nuevoVolumen
        player?.volume = nuevoVolumen
    }
}

// preguntas
struct PreguntaC: Codable, Identifiable {
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

// cargar preguntas
final class ChismeQuestionsService {
    func cargarPreguntasDesdeJSON(idioma: String) -> [PreguntaC] {
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
            let preguntas = try JSONDecoder().decode([PreguntaC].self, from: data)
            print("✅ Preguntas cargadas: \(preguntas.count) para el idioma \(idioma)")
            return preguntas
        } catch {
            print("❌ ERROR al decodificar JSON:", error)
            return []
        }
    }
}

// fondos
enum FondoChisme {
    case CHISME_NORMAL
    case GAME_OVER
    case DEFAULT
    
    static func fondo(para tema: String, gameOver: Bool) -> FondoChisme {
        if gameOver {
            return .GAME_OVER
        }
        
        switch tema {
        case "Gossip of Time", "Klatsch der Zeit", "Chismes del Tiempo":
            return .CHISME_NORMAL
        default:
            return .DEFAULT
        }
    }
}


final class ChismeViewModel: ObservableObject {
    
    @Published var preguntas: [PreguntaC] = []
    @Published var preguntaActual: PreguntaC?
    @Published var scoreActual: Int = 0
    @Published var mejorScore: Int = 0
    @Published var gameOver: Bool = false
    @Published var ultimaFueCorrecta: Bool? = nil
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var edadUsuario: Int?
    
    @AppStorage("selectedLanguage") private var selectedLanguageCode: String = "es"
    
    private let questionsService = ChismeQuestionsService()
    private let soundManager = Sonidos()
    private var preguntasDisponibles: [PreguntaC] = []
    
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
    
    // firebase y asi
    func cargarDatosUsuario() {
        self.isLoading = true
        self.errorMessage = nil
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ Usuario no autenticado. Usando valores por defecto.")
            self.edadUsuario = 9
            self.mejorScore = 0
            self.cargarPreguntasChisme()
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
                    self.cargarPreguntasChisme()
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
            
            // Cargar Score
            if let score = data["score_history"] as? Int {
                self.mejorScore = score
            } else if let scoreDouble = data["score_history"] as? Double {
                self.mejorScore = Int(scoreDouble)
            } else {
                self.mejorScore = 0
            }
            
            print("👤 Edad: \(self.edadUsuario ?? 9), Mejor Score Chisme: \(self.mejorScore)")
            
            DispatchQueue.main.async {
                self.cargarPreguntasChisme()
            }
        }
    }
    
    private func actualizarMejorScore() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ ERROR: Usuario no autenticado para guardar.")
            return
        }
        
        let docRef = Firestore.firestore().collection("users").document(userId)
        
        docRef.setData(["score_history": self.mejorScore], merge: true) { error in
            if let error = error {
                print("❌ ERROR al guardar score: \(error.localizedDescription)")
            } else {
                print("✅ Score de Chisme guardado: \(self.mejorScore)")
            }
        }
    }
    
    //cargar pregutnas
    func cargarPreguntasChisme() {
        guard let edadActual = self.edadUsuario else {
            self.isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let todas = self.questionsService.cargarPreguntasDesdeJSON(idioma: self.idiomaUsuario)
            
            let edadesPermitidas = Array(6...edadActual)
            
            let filtradas = todas.filter { pregunta in
                let idiomaPregunta = pregunta.idioma.lowercased()
                
                let idiomaMatch =
                    (idiomaPregunta.contains("español") || idiomaPregunta.contains("es")) && self.idiomaUsuario == "Español" ||
                    (idiomaPregunta.contains("english") || idiomaPregunta.contains("en")) && self.idiomaUsuario == "English" ||
                    (idiomaPregunta.contains("deutsch") || idiomaPregunta.contains("de")) && self.idiomaUsuario == "Deutsch"
                
                // rango ampliado de edades
                let edadMatch = pregunta.edad.contains(where: { edadesPermitidas.contains($0) })
                
                let temaMatch = pregunta.tema == "Gossip of Time" ||
                               pregunta.tema == "Klatsch der Zeit" ||
                               pregunta.tema == "Chismes del Tiempo"
                
                return idiomaMatch && edadMatch && temaMatch
            }
            
            if filtradas.isEmpty {
                self.errorMessage = "No hay preguntas de Chisme disponibles para idioma \(self.idiomaUsuario) y edad \(edadActual)"
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
    
// logica del juego
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


struct CHISMEVIEW: View {
    
    @StateObject private var vm = ChismeViewModel()
    @StateObject private var musica = MusicaChisme()
    @Environment(\.dismiss) var dismiss
    @State private var mostrarControles = false
    
    var body: some View {
        ZStack {
            // Siempre mostrar un fondo base
            Color.chisme.ignoresSafeArea()
            
            if vm.isLoading {
               
                ProgressView("Cargando...")
                    .foregroundStyle(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .font(.custom("GlacialIndifference-Bold", size: 50))
    
            } else {
                ZStack {
                    fondoDinamico()
                    
                    VStack {
                        if let error = vm.errorMessage {
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
                                .cornerRadius(12)
                            }
                            
                        } else if vm.gameOver {
                            vistaGameOver
                            
                        } else {
                            vistaJuego
                        }
                    }
                    
                    // Controles de música
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            if mostrarControles {
                                VStack(spacing: 15) {
                                    // Botón Play/Pause
                                    Button(action: {
                                        if musica.isPlaying {
                                            musica.pausar()
                                        } else {
                                            musica.reanudar()
                                        }
                                    }) {
                                        Image(systemName: musica.isPlaying ? "pause.fill" : "play.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                            .frame(width: 60, height: 60)
                                            .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                                            .clipShape(Circle())
                                    }
                                    
                                    // Control de volumen
                                    VStack(spacing: 5) {
                                        Text("Volumen")
                                            .font(.custom("GlacialIndifference-Bold", size: 14))
                                            .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                                        
                                        HStack {
                                            Image(systemName: "speaker.fill")
                                                .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                                            
                                            Slider(value: $musica.volume, in: 0...1, step: 0.1)
                                                .accentColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                                                .onChange(of: musica.volume) { newValue in
                                                    musica.cambiarVolumen(newValue)
                                                }
                                            
                                            Image(systemName: "speaker.wave.3.fill")
                                                .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                                        }
                                        .frame(width: 200)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(15)
                                .padding(.bottom, 80)
                                .padding(.trailing, 10)
                                .transition(.move(edge: .trailing))
                            }
                            
                            Button(action: {
                                withAnimation {
                                    mostrarControles.toggle()
                                }
                            }) {
                                Image(systemName: "music.note")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Circle())
                            }
                            .padding(.bottom, 20)
                            .padding(.trailing, 20)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            musica.iniciarMusica()
        }
        .onDisappear {
            musica.detener()
        }
        .onChange(of: vm.gameOver) { newValue in
            if newValue {
                musica.detener()
            }
        }
    }
    //fondos
    @ViewBuilder
    private func fondoDinamico() -> some View {
        let tema = vm.preguntaActual?.tema ?? ""
        let fondoCase = FondoChisme.fondo(para: tema, gameOver: vm.gameOver)
        
        ZStack {
            Color.white.ignoresSafeArea()
            
            switch fondoCase {
            case .CHISME_NORMAL:
                if let url = GIFS.GIFCHISME() {
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
                    .font(.system(size: 23, weight: .bold))
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .frame(maxWidth: 350, maxHeight: 200)
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.top, 80)
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
                                .font(.custom("GlacialIndifference-Bold", size: 20))
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
            .padding(.bottom, 150)
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
            
            // Boton "Volver a jugar"
            Button(action: {
                vm.reiniciarPartida()
                musica.iniciarMusica()
            }) {
                Text(LocalizedStringKey("Volver a jugar"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .cornerRadius(12)
            }
            
            // Boton "Menu"
            Button(action: {
                dismiss()
            }) {
                Text(LocalizedStringKey("Menú"))
                    .font(.title3)
                    .fontWeight(.bold)
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
    CHISMEVIEW()
}
