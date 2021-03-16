//
//  ControlView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

// Single view for any given AVR zone
struct ControlView: View {
    @ObservedObject var data: DataStore
    @State var zoneID: Int
    
    @EnvironmentObject var translate: Translate
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    @State private var isFrequencyValid: Bool = false

    var body: some View {
        VStack {
            HStack {
                ControlButton(onState: $data.controls[zoneID].powerOn, text: "Power", image: "power")
                    .modifier(ButtonModifier(onState: data.controls[zoneID].powerOn))
                    .disabled(!data.isConnected)
                    .onChange(of: data.controls[zoneID].powerOn, perform: { value in
                        translate.power(zoneID: zoneID, power: data.controls[zoneID].powerOn)
                        if data.controls[zoneID].powerOn {
                            translate.queryState(zoneID: zoneID)
                        } else {
                            data.controls[zoneID].speakersLive = false
                        }
                    })

                Spacer()
                
                ControlButton(onState: $data.controls[zoneID].speakersLive, text: "Audio", image: "speaker.fill")
                    .modifier(ButtonModifier(onState: data.controls[zoneID].speakersLive))
                    .disabled(!data.controls[zoneID].powerOn)
                    .onChange(of: data.controls[zoneID].speakersLive, perform: { value in
                        translate.mute(zoneID: zoneID, live: data.controls[zoneID].speakersLive)
                    })
            }
            
            Spacer()
            
            GroupBox(label: Label("Tuner", systemImage: "radio").foregroundColor(Color.backgroundColor)) {
                VStack {
                    HStack {
                        Button(action: { translate.tunerChangeDown(scan: false) },
                               label: { Image(systemName: "backward.end.alt").font(.system(size: 24)) }
                        )

                        Button(action: { translate.tunerChangeDown(scan: true) },
                               label: { Image(systemName: "backward").font(.system(size: 24)) }
                        )
                            
                        TextField("101.1", text: $data.tunerFrequncy)
                            .keyboardType(.numbersAndPunctuation)
                            .modifier(TextFieldModifier(colorState: isFrequencyValid))
                            .onChange(of: data.tunerFrequncy) { newValue in
                                isFrequencyValid = validateFrequency(test: newValue)
                                if (isFrequencyValid) {
                                    hideKeyboard()
                                    translate.tunerDirectDial(frequency: data.tunerFrequncy)
                                }
                            }
                        
                        Button(action: { translate.tunerChangeUp(scan: true) },
                               label: { Image(systemName: "forward").font(.system(size: 24)) }
                        )

                        Button(action: { translate.tunerChangeUp(scan: false) },
                               label: { Image(systemName: "forward.end.alt").font(.system(size: 24)) }
                        )
                    }
                    HStack {
                        Button(action: { translate.tunerPreset(preset: 1) },
                               label: { Image(systemName: "1.circle").font(.system(size: 24)) }
                        )
                        .padding(.horizontal, 20)
                        
                        Button(action: { translate.tunerPreset(preset: 2) },
                               label: { Image(systemName: "2.square").font(.system(size: 24)) }
                        )
                        .padding(.horizontal, 20)

                        Button(action: { translate.tunerPreset(preset: 3) },
                               label: { Image(systemName: "3.circle").font(.system(size: 24)) }
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            .accentColor(Color.onColor)
            .disabled(!data.controls[zoneID].powerOn || data.controls[zoneID].sourceInput != .tuner)

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
        .modifier(SceneModifier())
    }
    
    func validateFrequency(test: String) -> Bool {
        let am_pattern = "^([5-9][3-9][0]|1[0-6][0-9][0]|1700)$"
        let regexText_am = NSPredicate(format: "SELF MATCHES %@", am_pattern)
        let result_am = regexText_am.evaluate(with: test)

        let fm_pattern = "^(87.9|8[8-9].[13579]|9[0-9].[13579]|10[0-7].[13579]|1700)$"
        let regexText_fm = NSPredicate(format: "SELF MATCHES %@", fm_pattern)
        let result_fm = regexText_fm.evaluate(with: test)

        return result_am || result_fm
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView(data: DataStore(), zoneID: 1)
    }
}
