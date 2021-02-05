//
//  ControlView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import SwiftUI

enum SourceInput: String, CaseIterable, Identifiable, Equatable {
    case dvd = "DVD"
    case mediadevice = "TV"
    case tuner = "TUNER"

    var id: String { self.rawValue }
    
    static func == (lhs: SourceInput, rhs: SourceInput) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

struct ControlView: View {
    @Binding var isConnected: Bool
    var zoneID: Int
    
    @State private var t = Translate()

    @State private var powerOn: Bool = false
    @State private var speakersLive: Bool = false
    @State private var level: CGFloat = 20.0
    @State private var sourceInput = SourceInput.mediadevice

    var body: some View {
        VStack () {
            HStack() {
                Button(action: {
                    powerOn.toggle()
                    print(t.power(zoneID: zoneID, power: powerOn))
                }) {
                    HStack {
                        Text("Power")
                        Image(systemName: "power")
                    }
                }
                .frame(width: 100, height: 50)
                .foregroundColor(Color.white)
                .background(powerOn ? Color.onColor : Color.offColor)
                .cornerRadius(15.0)
                .padding(25)
                .disabled(!isConnected)

                Spacer()
                
                Button(action: {
                    speakersLive.toggle()
                    print(t.mute(zoneID: zoneID, live: speakersLive))
                }) {
                    HStack {
                        Image(systemName: speakersLive ? "speaker" : "speaker.slash")
                        Text("Audio")
                    }
                }
                .frame(width: 100, height: 50)
                .foregroundColor(Color.white)
                .background(speakersLive ? Color.onColor : Color.offColor)
                .cornerRadius(15.0)
                .padding(25)
                .disabled(!powerOn)
            }
            
            Spacer()
                                    
            RingView(color1: UIColor(Color.controlColor),
                     color2: UIColor(Color.errorColor),
                     width: 200,
                     height: 200,
                     percent: $level,
                     show: $powerOn)
            
            Stepper("", value: $level, in: 1...80)
                .labelsHidden()
                .padding(10)
                .disabled(!powerOn)
                .onChange(of: level, perform: { value in
                    print(t.volume(zoneID: zoneID, level: Int(level)))
                })
                .padding(.top, 50)

            Spacer()
            
            Picker("Source", selection: $sourceInput) {
                Text("DVD").tag(SourceInput.dvd)
                Text("Media Device").tag(SourceInput.mediadevice)
                Text("Tuner").tag(SourceInput.tuner)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(25)
            .padding(.bottom, 50)
            .disabled(!powerOn)
            .onChange(of: sourceInput, perform: { value in
                print(t.source(zoneID: zoneID, input: sourceInput))
            })
        }.onAppear {
            print("hi I'm here!")
        }
        .padding(.all, 25)
        .background(Color.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView(isConnected: .constant(true), zoneID: 1)
    }
}
