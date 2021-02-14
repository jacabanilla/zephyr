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
    
    private let network: NetworkStream
    private let translate: Translate
    
    init() {
        self.network = NetworkStream()
        self.translate = Translate(network: network)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(translate)
                .environmentObject(network)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                // Perform cleanup when all scenes within
                // MyScene go to the background.
                print("Yo")
            }
        }
    }
}
