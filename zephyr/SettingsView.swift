//
//  SwiftUIView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import SwiftUI

// Primarily a connection configuration interface
struct SettingsView: View {
    @ObservedObject var data: DataStore
    @EnvironmentObject var network: NetworkStream
    @EnvironmentObject var translate: Translate

    @State private var standbyOn: Bool = false

    @State private var ipAddress: String = ""
    @State private var isIPvalid: Bool = false
    @State private var avrCommand: String = ""
    
    
    var body: some View {
        VStack {
            HStack () {
                Button(action: {
                    standbyOn.toggle()
                    translate.standby(masterOn: standbyOn)
                }) {
                    HStack {
                        Text("Power")
                        Image(systemName: "power")
                    }
                }
                .modifier(ButtonModifier(onState: standbyOn))
                .disabled(!data.isConnected)

                Spacer()
                
                Button(action: {
                    if (!data.isConnected) {
                        data.isConnected = network.open(host: ipAddress, port: 23)
                    } else {
                        network.close()
                        data.isConnected.toggle()
                    }
                }) {
                    HStack {
                        Text("TCP ")
                        Image(systemName: "icloud.fill")
                    }
                }
                .modifier(ButtonModifier(onState: data.isConnected))
                .disabled(!isIPvalid)
            }
            
            Spacer()
            
            VStack () {
                Text("Network Address")
                TextField("192.168.198.132", text: $ipAddress)
                    .modifier(TextFieldModifier(colorState: isIPvalid))
                    .disabled(data.isConnected)
                    .onChange(of: ipAddress) { newValue in
                        isIPvalid = verifyWholeIP(test: ipAddress)
                    }
            }
            
            Spacer()
            
            VStack () {
                Text("Issue Command")
                TextField("MUON", text: $avrCommand) { isEditing in
                    } onCommit: {
                        print("issue command: " + avrCommand)
                        translate.generic(event: avrCommand)
                    }
                    .modifier(TextFieldModifier(colorState: true))
                    .padding(.bottom, 100)
                    .disabled(!data.isConnected)
            }
        }
        .padding(.all, 25)
        .background(Color.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }

    // will verify that the ip address is valid as it is being typed
    func verifyWhileTyping(test: String) -> Bool {
        let pattern_1 = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])[.]){0,3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])?$"
        let regexText_1 = NSPredicate(format: "SELF MATCHES %@", pattern_1)
        let result_1 = regexText_1.evaluate(with: test)
        return result_1
    }

    // will verify the the ip is fully constructed and proper
    func verifyWholeIP(test: String) -> Bool {
        let pattern_2 = "(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})"
        let regexText_2 = NSPredicate(format: "SELF MATCHES %@", pattern_2)
        let result_2 = regexText_2.evaluate(with: test)
        return result_2
    }
}



struct SettingsViewView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(data: DataStore())
    }
}
