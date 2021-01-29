//
//  ContentView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/16/21.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            
            SettingsView()
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }

            ControlView()
            .tabItem {
                Image(systemName: "tv.and.mediabox")
                Text("Living")
            }

            ControlView()
            .tabItem {
                Image(systemName: "laptopcomputer")
                Text("Office")
            }

            ControlView()
            .tabItem {
                Image(systemName: "bed.double")
                Text("Master")
            }

            ControlView()
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
