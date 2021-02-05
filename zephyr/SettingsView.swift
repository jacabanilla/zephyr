//
//  SwiftUIView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import SwiftUI


struct SettingsView: View {
    @Binding var network: NetworkStream
    @Binding var isConnected: Bool

    @State private var t = Translate()

    @State private var standbyOn: Bool = false

    @State private var ipAddress: String = ""
    @State private var avrCommand: String = ""
    
    @State private var isIPvalid: Bool = true
    
    var body: some View {
        VStack {
            HStack () {
                Button(action: {
                    standbyOn.toggle()
                    print(t.standby(masterOn: standbyOn))
                }) {
                    HStack {
                        Text("Power")
                        Image(systemName: "power")
                    }
                }
                .frame(width: 100, height: 50)
                .foregroundColor(Color.white)
                .background(standbyOn ? Color.onColor : Color.offColor)
                .cornerRadius(15.0)
                .padding(25)
                .disabled(!isConnected)

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
                .background(isConnected ? Color.onColor : Color.offColor)
                .cornerRadius(15.0)
                .padding(25)
                .disabled(!isIPvalid)
            }
            
            Spacer()
            
            VStack () {
                Text("Network Address")
                TextField("192.168.33.1", text: $ipAddress)
                .padding(.horizontal, 50)
                .multilineTextAlignment(.center)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(isIPvalid ? .offColor : .errorColor)
                .disabled(isConnected)
                .onChange(of: ipAddress) { newValue in
                    isIPvalid = verifyWholeIP(test: ipAddress)
                }
            }
            
            Spacer()
            
            VStack () {
                Text("Issue Command")
                TextField("MUON", text: $avrCommand) { isEditing in
                    } onCommit: {
                        print("issue command: " + t.generic(event: avrCommand))
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 100)
                    .multilineTextAlignment(.center)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!isConnected)
            }
        }
        .padding(.all, 25)
        .background(Color.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }

    func verifyWhileTyping(test: String) -> Bool {
        let pattern_1 = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])[.]){0,3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])?$"
        let regexText_1 = NSPredicate(format: "SELF MATCHES %@", pattern_1)
        let result_1 = regexText_1.evaluate(with: test)
        return result_1
    }

    func verifyWholeIP(test: String) -> Bool {
        let pattern_2 = "(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})"
        let regexText_2 = NSPredicate(format: "SELF MATCHES %@", pattern_2)
        let result_2 = regexText_2.evaluate(with: test)
        return result_2
    }
}



struct SettingsViewView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(network: .constant(NetworkStream()), isConnected: .constant(false))
    }
}
