//
//  ReviewMyThingApp.swift
//  ReviewMyThing
//
//  Created by Kent Karlsson on 2024-11-23.
//

import SwiftUI

// Add settings that can be accessed throughout the app
class Settings {
    static let shared = Settings()
    
    var openAIKey: String = "Add key here"
}

@main
struct CameraApp: App {
    init() {
        UINavigationBar.applyCustomAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
//            CameraView()
            ChooseYourAdventureView()
        }
    }
}

fileprivate extension UINavigationBar {
    
    static func applyCustomAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
