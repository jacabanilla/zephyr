//
//  SwiftUIView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import SwiftUI


struct SettingsView: View {
    @State var standbyOn: Bool = false
    @State var ipAddress: String = ""
    @State var isConnected: Bool = false
    @State var network = NetworkStream()
    @State var avrCommand: String = ""
    
    var body: some View {
        VStack {
            HStack () {
                Button(action: {
                    standbyOn.toggle()
                }) {
                    HStack {
                        Text("Power")
                        Image(systemName: "power")
                    }
                }
                .frame(width: 100, height: 50)
                .foregroundColor(Color.white)
                .background(standbyOn ? Color.green : Color.gray)
                .cornerRadius(15.0)
                .padding(25)

                Spacer()
                
                Button(action: {
                    if (!isConnected) {
                        isConnected = network.startNetworkComms(host: ipAddress)
                    } else {
                        network.stopNetworkComms()
                        isConnected.toggle()
                    }
                }) {
                    HStack {
                        Text("TCP ")
                        Image(systemName: isConnected ? "icloud.fill" : "icloud.slash.fill")
                    }
                }
                .frame(width: 100, height: 50)
                .foregroundColor(Color.white)
                .background(isConnected ? Color.green : Color.gray)
                .cornerRadius(15.0)
                .padding(25)
                .disabled(!standbyOn)
            }
            
            Spacer()
            
            VStack () {
                Text("Network Address")
                TextField("192.168.33.1", text: $ipAddress) { isEditing in

                    } onCommit: {
                        print("on commit")
                    }
                    .padding(.horizontal, 50)
                    .multilineTextAlignment(.center)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!standbyOn)

            }
            
            Spacer()
            
            VStack () {
                Text("Issue Command")
                TextField("MUON", text: $avrCommand) { isEditing in
//                    network.sendNetwork(message: "MUON\r")
//                    network.sendNetwork(message: "Z4OFF\r")
//                    network.sendNetwork(message: "Z4ON\r")
//                    Thread.sleep(forTimeInterval: 1)
//                    network.sendNetwork(message: "Z4TUNER\r")
//                    Thread.sleep(forTimeInterval: 1)
//                    network.sendNetwork(message: "Z4?\r")
                    } onCommit: {
                        print("issue command")
                        network.sendNetwork(message: avrCommand + "\r")
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 50)
                    .multilineTextAlignment(.center)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!standbyOn)
            }
        }
    }
}



struct SettingsViewView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
