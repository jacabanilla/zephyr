//
//  zephyrApp.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/16/21.
//

import SwiftUI

@main
struct zephyrApp: App {
    @Environment(\.scenePhase) private var scenePhase
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(NetworkStream())
                .environmentObject(Translate())
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                // Perform cleanup when all scenes within
                // MyScene go to the background.
            }
        }
    }
}
