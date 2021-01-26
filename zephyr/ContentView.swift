//
//  ContentView.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/16/21.
//

import SwiftUI

struct ContentView: View {
    @State var vibrateOnRing = true
    
    var body: some View {
        TabView {
            
            ConfigureView()
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }

            ControlView()
            .tabItem {
                Image(systemName: "tv.and.mediabox")
                Text("Living")
            }

            ControlView()
            .tabItem {
                Image(systemName: "laptopcomputer")
                Text("Office")
            }

            ControlView()
            .tabItem {
                Image(systemName: "bed.double")
                Text("Master")
            }

            ControlView()
            .tabItem {
                Image(systemName: "lifepreserver")
                Text("Pool")
            }
        }
    }
}

struct ConfigureView: View {
    
    @State var network = NetworkCommStream()

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
                    print("Power changed")
                }) {
                    HStack {
                        Text("Zone")
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
                    print("Mute Changed")
                }) {
                    HStack {
                        Image(systemName: "speaker")
                        Text("Live")
                    }
                }
                .frame(width: 100, height: 50)
                .foregroundColor(Color.white)
                .background(speakersLive ? Color.green : Color.gray)
                .cornerRadius(15.0)
                .padding(25)
            }
            
            Spacer()
                        
            RingView(color1: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), color2: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), width: 200, height: 200, percent: $level, show: .constant(true))
            
            Stepper("", value: $level, in: 1...80)
                .labelsHidden()
                .padding(10)
                .onChange(of: level, perform: { value in
                    print("New Level \(level)")
                })
            
            Spacer()
            
            Picker("Source", selection: $sourceInput) {
                Text("DVD").tag(SourceInput.dvd)
                Text("Media Device").tag(SourceInput.mediadevice)
                Text("FM").tag(SourceInput.tuner)
            }
            .onChange(of: sourceInput, perform: { value in
                print("\(value.rawValue)")
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding(20)
        }
    }
}

struct RingView: View {
    var color1 = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    var color2 = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
    var width: CGFloat = 300
    var height: CGFloat = 300
    @Binding var percent: CGFloat
    @Binding var show: Bool
    
    var body: some View {
        let multiplier = width / 44
        let progress = 1 - (percent / 100)
        let dBoffset = 80
        
        return ZStack {
            Circle()
                .stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 5 * multiplier))
                .frame(width: width, height: height)
            
            Circle()
                .trim(from: show ? progress : 1, to: 1)
                .stroke(
                    LinearGradient(gradient: Gradient(colors: [Color(color1), Color(color2)]), startPoint: .topTrailing, endPoint: .bottomLeading),
                    style: StrokeStyle(lineWidth: 5 * multiplier, lineCap: .round, lineJoin: .round, miterLimit: .infinity, dash: [20, 0], dashPhase: 0)
                )
                .rotationEffect(Angle(degrees: 90))
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .frame(width: width, height: height)
                .shadow(color: Color(color2).opacity(0.1), radius: 3 * multiplier, x: 0, y: 3 * multiplier)
            
            Text("\(Int(percent) - dBoffset)dB")
                .font(.system(size: 10 * multiplier))
                .fontWeight(.bold)
                .onTapGesture {
                    self.show.toggle()
            }
        }
    }
}

class NetworkCommStream :NSObject {
    public var inStream: InputStream!
    public var outStream: OutputStream!
    let maxReadLength = 4096

    func startNetworkComms() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        let host = "192.168.198.132"
        let port = UInt32(23)
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           host as CFString,
                                           port,
                                           &readStream,
                                           &writeStream)

        inStream = readStream!.takeRetainedValue()
        outStream = writeStream!.takeRetainedValue()
        
        inStream.delegate = self
        outStream.delegate = self

        inStream.schedule(in: .current, forMode: .default)
        outStream.schedule(in: .current, forMode: .default)

        inStream.open()
        outStream.open()
        
        let numberOfRingsMax = 10
        var numberOfRings = 0
        
        for _ in 0 ... numberOfRingsMax {
            numberOfRings += 1
            Thread.sleep(forTimeInterval: 0.001)

            if (inStream.streamStatus == .open) && (outStream.streamStatus == .open) {
                    break
            }
        }
        
        _ = (numberOfRings == numberOfRingsMax) ? false : true;
    }

    func stopNetworkComms() {
        inStream.close()
        outStream.close()
    }

    func sendNetwork(message: String) {
        let data = message.data(using: .utf8)!
      
        data.withUnsafeBytes {
        guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          print("Error joining chat")
          return
        }
            
        outStream.write(pointer, maxLength: data.count)
      }
    }

    private func readAvailableBytes(stream: InputStream, maxReadLength: Int) {
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        var msg = String()
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = stream.read(buffer, maxLength: maxReadLength)
        
            if numberOfBytesRead < 0, let error = stream.streamError {
              print(error)
              break
            }

            // Construct the message object
            let data = Data(bytes: buffer, count: numberOfBytesRead)
            msg += String(decoding: data, as: UTF8.self)
        }
        
        print(msg)
    }
}

extension NetworkCommStream: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
            case .hasBytesAvailable:
                print("new message received")
                readAvailableBytes(stream: aStream as! InputStream, maxReadLength: maxReadLength)
            case .endEncountered:
                print("end received")
                stopNetworkComms()
            case .errorOccurred:
                print("error occurred")
            case .hasSpaceAvailable:
                print("has space available")
            default:
                print("some other event...")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
