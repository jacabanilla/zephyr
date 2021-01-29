//
//  SwiftUIView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import SwiftUI


struct SettingsView: View {
    
    @State var network = NetworkStream()

    var body: some View {
        HStack () {
            Button (action: {
                print("open")
                network.startNetworkComms()
            }) {
                Text("open")
            }
            Button (action: {
                print("query")
//                    network.sendNetwork(message: "MUON\r")
//                    network.sendNetwork(message: "Z4OFF\r")
//                    network.sendNetwork(message: "Z4ON\r")
//                    Thread.sleep(forTimeInterval: 1)
//                    network.sendNetwork(message: "Z4TUNER\r")
//                    Thread.sleep(forTimeInterval: 1)
//                    network.sendNetwork(message: "Z4?\r")
            }) {
                Text("query")
            }
            Button (action: {
                print("close")
                network.stopNetworkComms()
            }) {
                Text("close")
            }
        }
    }
}



struct SettingsViewView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
