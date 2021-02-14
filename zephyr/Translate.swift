//
//  Translate.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 2/4/21.
//

import Foundation

class Translate: ObservableObject {
    @Published var request = String()
    
    private let query = "?"
    private let cr = "\r"
    
    // Parsing functionality
    func parse(reply: String, data: DataStore) {
        let value = true
        data.controls[0].powerOn = value
    }
//    func parse(reply: String) -> [(Int, Any, Any)] {
//        var listOfCommands = [(Int, Any, Any)]()
//
//        let commands = reply.split(separator: "\r")
//        for command in commands {
//            let length = command.count
//            if length < 3 {
//                break
//            }
//
//            let cmd: String = String(command.prefix(2))
//            let param: String = String(command.suffix(length - 2))
//
//            switch (cmd, param) {
//                case (cmdStandby, _):
//                    listOfCommands += [("FIX_ME", param == "ON")]
//
//                case ("ZM", _),
//                     ("Z1", "ON"), ("Z2", "ON"), ("Z3", "ON"),
//                     ("Z1", "OFF"), ("Z2", "OFF"), ("Z3", "OFF"):
//                    listOfCommands += [(\ControlData.powerOn, param == "ON")]
//
//                case ("MU", _), ("Z1MU", _), ("Z2MU", _), ("Z3MU", _):
//                    listOfCommands += [(\ControlData.speakersLive, param == "ON")]
//
//                case ("MV", _), ("Z1", _), ("Z2", _), ("Z3", _):
//                    listOfCommands += [(\ControlData.level, param.prefix(2))]
//
//                case ("SI", _), ("Z1SI", _), ("Z2SI", _), ("Z3SI", _):
//                    listOfCommands += [(\ControlData.sourceInput, param)]
//
//                default:
//                    break
//            }
//
//            return listOfCommands
//        }
//
//        return listOfCommands
//    }
    
    // Freeform Command
    func generic(event: String) {
        request = event + cr
    }

    // Master Unit Specific Command
    func standby(masterOn: Bool? = nil) {
        let command = "PW"

        if let masterOn = masterOn {
            let code = (masterOn) ? "ON" : "STANDBY"
            
            request = command + code + cr
        }
        
        request = command + query + cr
    }
    
    // Zone Specific Commands
    func power(zoneID: Int, power: Bool? = nil) {
        let command = (zoneID == 0) ? "ZM" : "Z" + "\(zoneID)"

        if let power = power {
            let code = (power) ? "ON" : "OFF"
            
            request = command + code + cr
        }
        
        request = command + query + cr
    }

    func mute(zoneID: Int, live: Bool? = nil) {
        let command = (zoneID == 0) ? "" : "Z" + "\(zoneID)"
        
        if let live = live {
            let code = "MU" + (live ? "ON" : "OFF")
            
            request = command + code + cr
        }

        request = command + query + cr
    }
    
    func volume(zoneID: Int, level: Int? = nil) {
        let command = (zoneID == 0) ? "MV" : "Z" + "\(zoneID)"
        
        if let level = level {
            let code = "\(level)"
            
            request = command + code + cr
        }

        request = command + query + cr
    }
    
    func source(zoneID: Int, input: SourceInput? = nil) {
        let command = (zoneID == 0) ? "SI" : "Z" + "\(zoneID)"
        
        if let input = input {
            let code = input.rawValue
            
            request = command + code + cr
        }

        request = command + query + cr
    }
}
