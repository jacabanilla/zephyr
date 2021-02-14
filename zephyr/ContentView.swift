//
//  ContentView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/16/21.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var data: DataStore = DataStore()
    @EnvironmentObject var network: NetworkStream
    @State var mySubscriber: AnyCancellable?

    var body: some View {
        TabView {
            SettingsView(data: data)
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }

            ControlView(data: data, zoneID: 1)
            .tabItem {
                Image(systemName: "tv.and.mediabox")
                Text("Living")
            }

            ControlView(data: data, zoneID: 2)
            .tabItem {
                Image(systemName: "laptopcomputer")
                Text("Office")
            }

            ControlView(data: data, zoneID: 3)
            .tabItem {
                Image(systemName: "bed.double")
                Text("Master")
            }

            ControlView(data: data, zoneID: 4)
            .tabItem {
                Image(systemName: "lifepreserver")
                Text("Pool")
            }
            
        } .onAppear {
            // Primary processing method for any observed changes to msg
            mySubscriber = network.$reply.sink(receiveValue: { reply in
                print("received " + reply)
            })
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
