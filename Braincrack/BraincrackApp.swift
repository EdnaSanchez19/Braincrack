//
//  BraincrackApp.swift
//  Braincrack
//
//  Created by Edna Sanchez  on 20/09/25.
//

import SwiftUI
import FirebaseCore

@main
struct BraincrackApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "es"

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            INICIO()
                .environment(\.locale, Locale(identifier: selectedLanguage))
        }
    }
}

