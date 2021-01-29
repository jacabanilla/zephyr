//
//  ControlView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import SwiftUI

enum SourceInput: String, CaseIterable, Identifiable, Equatable {
    case dvd
    case mediadevice
    case tuner

    var id: String { self.rawValue }
    
    static func == (lhs: SourceInput, rhs: SourceInput) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

struct ControlView: View {
    @State private var zoneID: Int = 1
    @State private var powerOn: Bool = false
    @State private var speakersLive: Bool = true
    @State private var level: CGFloat = 20.0
    @State private var sourceInput = SourceInput.mediadevice

    var body: some View {
        VStack () {
            HStack() {
                Button(action: {
                    powerOn.toggle()
                }) {
                    HStack {
                        Text("Power")
                        Image(systemName: "power")
                    }
                }
                .frame(width: 100, height: 50)
                .foregroundColor(Color.white)
                .background(powerOn ? Color.green : Color.gray)
                .cornerRadius(15.0)
                .padding(25)

                Spacer()
                
                Button(action: {
                    speakersLive.toggle()
                }) {
                    HStack {
                        Image(systemName: speakersLive ? "speaker" : "speaker.slash")
                        Text("Audio")
                    }
                }
                .frame(width: 100, height: 50)
                .foregroundColor(Color.white)
                .background(speakersLive ? Color.green : Color.gray)
                .cornerRadius(15.0)
                .padding(25)
                .disabled(!powerOn)
            }
            
            Spacer()
                                    
            RingView(color1: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), color2: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), width: 200, height: 200, percent: $level, show: $powerOn)
            
            Stepper("", value: $level, in: 1...80)
                .labelsHidden()
                .padding(10)
                .disabled(!powerOn)
                .onChange(of: level, perform: { value in
                    print("New Level \(level)")
                })

            Spacer()
            
            Picker("Source", selection: $sourceInput) {
                Text("DVD").tag(SourceInput.dvd)
                Text("Media Device").tag(SourceInput.mediadevice)
                Text("FM").tag(SourceInput.tuner)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(20)
            .disabled(!powerOn)
            .onChange(of: sourceInput, perform: { value in
                print("\(value.rawValue)")
            })
        }
    }
}
struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView()
    }
}
