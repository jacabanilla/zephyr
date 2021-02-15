//
//  ControlView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import SwiftUI

struct ControlView: View {
    @ObservedObject var data: DataStore
    @State var zoneID: Int
    
    @EnvironmentObject var translate: Translate


    var body: some View {
        VStack () {
            HStack() {
                Button(action: {
                    data.controls[zoneID].powerOn.toggle()
                    translate.power(zoneID: zoneID, power: data.controls[zoneID].powerOn)
                }) {
                    HStack {
                        Text("Power")
                        Image(systemName: "power")
                    }
                }
                .frame(width: 100, height: 50)
                .foregroundColor(Color.white)
                .background(data.controls[zoneID].powerOn ? Color.onColor : Color.offColor)
                .cornerRadius(15.0)
                .padding(25)
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
                .frame(width: 100, height: 50)
                .foregroundColor(Color.white)
                .background(data.controls[zoneID].speakersLive ? Color.onColor : Color.offColor)
                .cornerRadius(15.0)
                .padding(25)
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
                Text("Media Device").tag(SourceInput.mediadevice)
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
            // Upon this view being loaded, query of the state of AVR
            translate.queryState(zoneID: zoneID)
        }
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
