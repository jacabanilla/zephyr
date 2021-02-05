//
//  ContentView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/16/21.
//

import SwiftUI

struct ContentView: View {
    @State private var isConnected: Bool = false

    var body: some View {
        TabView {
            SettingsView(isConnected: $isConnected)
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }

            ControlView(isConnected: $isConnected, zoneID: 1)
            .tabItem {
                Image(systemName: "tv.and.mediabox")
                Text("Living")
            }

            ControlView(isConnected: $isConnected, zoneID: 2)
            .tabItem {
                Image(systemName: "laptopcomputer")
                Text("Office")
            }

            ControlView(isConnected: $isConnected, zoneID: 3)
            .tabItem {
                Image(systemName: "bed.double")
                Text("Master")
            }

            ControlView(isConnected: $isConnected, zoneID: 4)
            .tabItem {
                Image(systemName: "lifepreserver")
                Text("Pool")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
