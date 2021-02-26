//
//  ContentView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/16/21.
//

import SwiftUI
import Combine

// Main tab scene creating the data store and network management
struct ContentView: View {
    @StateObject var data: DataStore = DataStore()
    @EnvironmentObject var network: NetworkStream
    @EnvironmentObject var translate: Translate
    @State var myTxSubscriber: AnyCancellable?
    @State var myRxSubscriber: AnyCancellable?

    var body: some View {
        TabView {
            SettingsView(data: data)
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }

            ControlView(data: data, zoneID: 0)
            .tabItem {
                Image(systemName: "tv.and.mediabox")
                Text("Living")
            }

            ControlView(data: data, zoneID: 1)
            .tabItem {
                Image(systemName: "laptopcomputer")
                Text("Office")
            }

            ControlView(data: data, zoneID: 2)
            .tabItem {
                Image(systemName: "bed.double")
                Text("Master")
            }

            ControlView(data: data, zoneID: 3)
            .tabItem {
                Image(systemName: "lifepreserver")
                Text("Pool")
            }
            
        } .onAppear {
            // Primary processing method for any observed changes to msg (inbound)
            myRxSubscriber = network.$reply.sink(receiveValue: { reply in
                print("received " + reply)
                translate.parse(reply: reply, data: data)
            })
            
            // Primary processing method for any requested changes to send (outbound)
            myTxSubscriber = translate.$request.sink(receiveValue: { request in
                print("transmit " + request)
                network.transmit(message: request)
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
