//
//  LIBREVIEW.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 19/11/25.
//


import SwiftUI
import Foundation
import AVFoundation
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI

// sonido
final class sonidos7 {
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
final class MusicaLibre: ObservableObject {
    private var player: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 0.5
    
    func iniciarMusica() {
        guard let url = Bundle.main.url(forResource: "libre", withExtension: "mp3") else {
            print("❌ ERROR: No se encontró el archivo libre.mp3")
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

// variables
struct PreguntaLibre: Codable, Identifiable {
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

// json preguntas
final class LocalQuestionsServiceLibre {
    func cargarPreguntasDesdeJSON() -> [PreguntaLibre] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            print("❌ ERROR: No se encontró questions.json. Retornando vacío.")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let preguntas = try JSONDecoder().decode([PreguntaLibre].self, from: data)
            print("✅ Preguntas cargadas desde JSON: \(preguntas.count)")
            return preguntas
        } catch {
            print("❌ ERROR al decodificar JSON:", error)
            return []
        }
    }
}

// fondos
enum FondoTemaLibre {
    case DATONAUTA
    case CHISMESITOHISTORICO
    case EXACTAMANIACAA
    case LOMBRILETRAS
    case GEOGEBRA
    case PERDISTE
    case DEFAULT
    
    static func fondo(para tema: String, sinVidas: Bool) -> FondoTemaLibre {
        if sinVidas {
            return .PERDISTE
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

// declarar variable con json y asi
final class ModoLibreViewModel: ObservableObject {
    
    @Published var preguntas: [PreguntaLibre] = []
    @Published var preguntaActual: PreguntaLibre?
    @Published var scoreActual: Int = 0
    @Published var mejorScore: Int = 0
    @Published var vidasRestantes: Int = 3
    @Published var gameOver: Bool = false
    @Published var ultimaFueCorrecta: Bool? = nil
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    @Published var edadUsuario: Int?
    
    @AppStorage("selectedLanguage") private var selectedLanguageCode: String = "es"
    
    private let questionsService = LocalQuestionsServiceLibre()
    private var preguntasDisponibles: [PreguntaLibre] = []
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
        cargarDatosUsuario()
    }
    
    // carga edad y asi de firebase
    func cargarDatosUsuario() {
        self.isLoading = true
        self.errorMessage = nil
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ USUARIO NO AUTENTICADO. Usando edad por defecto (9) y score (0).")
            self.edadUsuario = 9
            self.mejorScore = 0
            self.cargarPreguntasLocales()
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
            
            // Cargar Edad
            if let age = data["age"] as? Int {
                self.edadUsuario = age
            } else if let ageDouble = data["age"] as? Double {
                self.edadUsuario = Int(ageDouble)
            } else {
                print("⚠️ Campo 'age' no encontrado o inválido. Usando edad por defecto (9).")
                self.edadUsuario = 9
            }
            
            // Cargar Mejor Score del Modo Libre
            if let score = data["score_free"] as? Int {
                self.mejorScore = score
            } else if let scoreDouble = data["score_free"] as? Double {
                self.mejorScore = Int(scoreDouble)
            } else {
                print("⚠️ Campo 'score_free' no encontrado o inválido. Usando score por defecto (0).")
                self.mejorScore = 0
            }
            
            print("👤 Datos cargados: Edad: \(self.edadUsuario ?? 9), Mejor Score: \(self.mejorScore)")
            
            self.cargarPreguntasLocales()
        }
    }
    
    //guarda en firebase
    private func actualizarMejorScore() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ ERROR al guardar: Usuario no autenticado para guardar el récord.")
            return
        }
        
        let docRef = Firestore.firestore().collection("users").document(userId)
        
        docRef.setData(["score_free": self.mejorScore], merge: true) { error in
            if let error = error {
                print("❌ ERROR al guardar el mejor score en Firestore: \(error.localizedDescription)")
            } else {
                print("✅ Mejor score (\(self.mejorScore)) guardado exitosamente.")
            }
        }
    }

    // logica de las preguntas
    func cargarPreguntasLocales() {
        guard let edadActual = self.edadUsuario else {
            self.isLoading = false
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let todas = self.questionsService.cargarPreguntasDesdeJSON()
            
            // Crear lista de edades permitidas: desde edadActual hasta 6
            let edadesPermitidas = Array(6...edadActual)
            
            let filtradas = todas.filter {
                // Filtro por idioma
                let idiomaMatch =
                ($0.idioma == self.idiomaUsuario) ||
                ($0.idioma.lowercased().contains(self.selectedLanguageCode.lowercased()))
                
                // Filtro por edad: cualquier edad dentro del rango permitido
                let edadMatch = $0.edad.contains(where: { edadesPermitidas.contains($0) })
                
                return idiomaMatch && edadMatch
            }
            
            if filtradas.isEmpty {
                self.errorMessage = "No hay preguntas disponibles para el idioma \(self.idiomaUsuario) y edad \(edadActual)"
                self.isLoading = false
                return
            }
            
            self.preguntas = filtradas
            self.preguntasDisponibles = filtradas.shuffled()
            self.scoreActual = 0
            self.vidasRestantes = 3
            self.ultimaFueCorrecta = nil
            self.isLoading = false
            self.gameOver = false
            self.siguientePregunta()
        }
    }
    
    // logica del juego
    
    private func terminarJuego() {
        gameOver = true
        if scoreActual > mejorScore {
            mejorScore = scoreActual
            actualizarMejorScore()
        }
    }
    
    func reiniciarPartida() {
        preguntasDisponibles = preguntas.shuffled()
        scoreActual = 0
        vidasRestantes = 3
        gameOver = false
        ultimaFueCorrecta = nil
        siguientePregunta()
    }
    
    func responder(opcion: String) {
        guard let actual = preguntaActual else { return }
              
        if opcion == actual.respc {
            ultimaFueCorrecta = true
            scoreActual += 10
            playSound("ding")
            siguientePregunta()
        } else {
            ultimaFueCorrecta = false
            vidasRestantes -= 1
            playSound("error")
            
            if vidasRestantes <= 0 {
                terminarJuego()
            } else {
                siguientePregunta()
            }
        }
    }
    
    private func siguientePregunta() {
        if vidasRestantes <= 0 {
            terminarJuego()
            return
        }
              
        guard !preguntasDisponibles.isEmpty else {
            terminarJuego()
            return
        }
              
        preguntaActual = preguntasDisponibles.removeFirst()
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

// vista
struct LIBREVIEW: View {
    @StateObject private var vm = ModoLibreViewModel()
    @StateObject private var musica = MusicaLibre()
    @Environment(\.dismiss) var dismiss
    @State private var mostrarControles = false
    
    var body: some View {
        ZStack {
            // Siempre mostrar un fondo base
            Color.geo.ignoresSafeArea()
            
            if vm.isLoading {
               
                ProgressView("Cargando...")
                    .foregroundStyle(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .font(.custom("GlacialIndifference-Bold", size: 50))
                    
                    
            } else {
                //
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
    // fondos de gif
    @ViewBuilder
    private func fondoDinamico() -> some View {
        let tema = vm.preguntaActual?.tema ?? "DEFAULT"
        let fondoCase = FondoTemaLibre.fondo(para: tema, sinVidas: vm.vidasRestantes <= 0 && vm.gameOver)
        
        ZStack {
            Color.white.ignoresSafeArea()
            
            Group {
                switch fondoCase {
                case .DATONAUTA:
                    AnimatedImage(url: GIFS.GIFDATINAUTA())
                        .resizable()
                        .customLoopCount(0)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                case .CHISMESITOHISTORICO:
                    AnimatedImage(url: GIFS.GIFCHISME())
                        .resizable()
                        .customLoopCount(0)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                case .EXACTAMANIACAA:
                    AnimatedImage(url: GIFS.GIFMENTEEXACTA())
                        .resizable()
                        .customLoopCount(0)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                case .LOMBRILETRAS:
                    AnimatedImage(url: GIFS.GIFLETRINAS())
                        .resizable()
                        .customLoopCount(0)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                case .GEOGEBRA:
                    AnimatedImage(url: GIFS.GIFGEOEXPLORA())
                        .resizable()
                        .customLoopCount(0)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                case .PERDISTE:
                    AnimatedImage(url: GIFS.GIFSEACABOELTIEMPO())
                        .resizable()
                        .customLoopCount(0)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                case .DEFAULT:
                    Color.gray.opacity(0.1)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    private var vistaJuego: some View {
        VStack(spacing: 15) {
            // Mostrar vidas restantes
            HStack {
                ForEach(0..<3) { index in
                    Image(systemName: index < vm.vidasRestantes ? "heart.fill" : "heart")
                        .foregroundColor(index < vm.vidasRestantes ? .red : .gray)
                        .font(.title2)
                }
            }
            .padding(.top, 60)
            
            if let pregunta = vm.preguntaActual {
                Text(pregunta.pregunta)
                    .font(.custom("GlacialIndifference-Bold", size: 25))
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .frame(maxWidth: 300, maxHeight: 200)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
            }
            
            Text("Puntaje actual: \(vm.scoreActual)")
                .font(.custom("GlacialIndifference-Bold", size: 20))
                .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                .padding(.top, 80)
            
            VStack(spacing: 15) {
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
                .padding(.top, 100)
                .padding(.trailing, 10)
            
            VStack(spacing: 10) {
                Text(LocalizedStringKey("Tu puntaje"))
                    .font(.title3)
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .padding(.trailing, 10)
                
                Text("\(vm.scoreActual)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .padding(.trailing, 10)
                
                Text(LocalizedStringKey("Récord"))
                    .font(.title2)
                    .foregroundColor(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .padding(.trailing, 10)
                Text(" \(vm.mejorScore)")
                    .padding(.trailing, 10)
            }
            .padding(.top, 200)
        
            Button(action: {
                vm.reiniciarPartida()
                musica.iniciarMusica()
            }) {
                Text(LocalizedStringKey("Volver a intentar"))
                    .font(.custom("GlacialIndifference-Bold", size: 20))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color(red: 0.1922, green: 0.0, blue: 0.3843))
                    .cornerRadius(12)
            }
            .padding(.trailing, 10)
            
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
            .padding(.trailing, 10)
        }
    }
}

#Preview {
    LIBREVIEW()
}
