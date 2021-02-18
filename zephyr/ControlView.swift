//
//  ControlView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import SwiftUI

// Single view for any given AVR zone
struct ControlView: View {
    @ObservedObject var data: DataStore
    @State var zoneID: Int
    
    @EnvironmentObject var translate: Translate
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack () {
            HStack() {
                Button(action: {
                    data.controls[zoneID].powerOn.toggle()
                    if data.controls[zoneID].powerOn {
                        translate.queryState(zoneID: zoneID)
                    }
                    translate.power(zoneID: zoneID, power: data.controls[zoneID].powerOn)
                }) {
                    HStack {
                        Text("Power")
                        Image(systemName: "power")
                    }
                }
                .modifier(ButtonModifier(onState: data.controls[zoneID].powerOn))
                .disabled(!data.isConnected)

                Spacer()
                
                Button(action: {
                    data.controls[zoneID].speakersLive.toggle()
                    translate.mute(zoneID: zoneID, live: data.controls[zoneID].speakersLive)
                }) {
                    HStack {
                        Image(systemName: data.controls[zoneID].speakersLive ? "speaker" : "speaker.slash")
                        Text("Audio")
                    }
                }
                .modifier(ButtonModifier(onState: data.controls[zoneID].speakersLive))
                .disabled(!data.controls[zoneID].powerOn)
            }
            
            Spacer()
                                    
            RingView(color1: UIColor(Color.controlColor),
                     color2: UIColor(Color.errorColor),
                     width: 200,
                     height: 200,
                     percent: $data.controls[zoneID].level,
                     show: $data.controls[zoneID].powerOn)
            
            Stepper("", value: $data.controls[zoneID].level, in: 1...80)
                .labelsHidden()
                .padding(10)
                .disabled(!data.controls[zoneID].powerOn)
                .onChange(of: data.controls[zoneID].level, perform: { value in
                    print("volume is: \(value)" )
                    translate.volume(zoneID: zoneID, level: Int(data.controls[zoneID].level))
                })
                .padding(.top, 50)

            Spacer()
            
            Picker("Source", selection: $data.controls[zoneID].sourceInput) {
                Text("DVD").tag(SourceInput.dvd)
                Text("Media").tag(SourceInput.mediadevice)
                Text("Tuner").tag(SourceInput.tuner)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(25)
            .padding(.bottom, 50)
            .disabled(!data.controls[zoneID].powerOn)
            .onChange(of: data.controls[zoneID].sourceInput, perform: { value in
                print("source is: \(value)" )
                translate.source(zoneID: zoneID, input: data.controls[zoneID].sourceInput)
            })
        } .onAppear {
            // When this view is loaded, query of the state of AVR and set the UI
            translate.queryState(zoneID: zoneID)
        } .onReceive(timer, perform: { _ in
            // Periodically check to see if a change has been made from the panel or remote
            translate.queryState(zoneID: zoneID)
        })
        .padding(.all, 25)
        .background(Color.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView(data: DataStore(), zoneID: 1)
    }
}
