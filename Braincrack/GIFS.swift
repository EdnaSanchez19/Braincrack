//
//  GIFS.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 20/09/25.
//


import SwiftUI
import SDWebImageSwiftUI

//MANAGER DE GIFS PARA BRAINCRACK
struct GIFS: View {
    
    // Función principal esta funcion manda a llamar o encontrar el gif (tiene que estar dentro de la carpeta de trabajo( el nombre se cambia p), le puse nombre: String por que en cada funcion se le cambiara el nombre y evitar alargar el codigo
    
    static func obtenerGif(nombre: String) -> URL? {
        guard let bundle = Bundle.main.path(forResource: nombre, ofType: "gif") else {
            //nil es un valor nulo, entonces si el gif no funciona o no lo encuentra lo que arroja no sera nada y no error
            return nil
        }
        return URL(fileURLWithPath: bundle)
    }
    
    // FONDOS DE PANTALLA
    
    static func GIFINICIO() -> URL? {
        return obtenerGif(nombre: "INICIO")
    }
    
    static func GIFINICIOSESION() -> URL? {
        return obtenerGif(nombre: "INICIOSESION")
    }
    
    static func GIFMODODEJUEGO() -> URL? {
        return obtenerGif(nombre: "MODODEJUEGO")
    }
    
    static func GIFNOOPORTUNIDADES() -> URL? {
        return obtenerGif(nombre: "NOOPORTUNIDADES")
    }
    
    static func GIFSEACABOELTIEMPO() -> URL? {
        return obtenerGif(nombre: "SEACABOELTIEMPO")
    }
    
    static func GIFSEACABO() -> URL? {
        return obtenerGif(nombre: "SEACABO")
    }
    
    static func GIFLETRINAS() -> URL? {
        return obtenerGif(nombre: "LOMBRILETRAS")
    }
    
    static func GIFMENTEEXACTA() -> URL? {
        return obtenerGif(nombre: "EXACTAMANIACAA")
    }
    
    static func GIFGEOEXPLORA() -> URL? {
        return obtenerGif(nombre: "GEOGEBRA")
    }
    
    static func GIFDATINAUTA() -> URL? {
        return obtenerGif(nombre: "DATONAUTA")
    }
    
    static func GIFCHISME() -> URL? {
        return obtenerGif(nombre: "CHISMESITOHISTORICO")
    }
    static func GIFTEMAS() -> URL? {
        return obtenerGif(nombre: "TEMAS")
    }

    
    // ANIMACIONES
    static func GIFCARGANDO() -> URL? {
        return obtenerGif(nombre: "loading")
    }
    
    static func GIFOPENING() -> URL? {
        return obtenerGif(nombre: "OPENING2")
    }
    
    static func GIFPENSANDO() -> URL? {
        return obtenerGif(nombre: "thinking")
    }
    
    // MARK: - GIFs de Efectos
    static func GIFPARTICULAS() -> URL? {
        return obtenerGif(nombre: "particles")
    }
    
    static func GIFEXPLOSION() -> URL? {
        return obtenerGif(nombre: "explosion")
    }
    
    static func GIFCHISPAS() -> URL? {
        return obtenerGif(nombre: "sparks")
    }
    
    // MARK: - GIFs de Botones
    static func GIFBOTONPLAY() -> URL? {
        return obtenerGif(nombre: "button_play")
    }
    
    static func GIFBOTONPAUSE() -> URL? {
        return obtenerGif(nombre: "button_pause")
    }
    
    // MARK: - Body requerido para View
    var body: some View {
        Text("Manager de GIFs")
            .font(.title)
            .padding()
    }
}

#Preview {
    GIFS()
}
