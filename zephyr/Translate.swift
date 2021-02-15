//
//  Translate.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 2/4/21.
//

import Foundation
import CoreGraphics

class Translate: ObservableObject {
    @Published var request = String()
    
    private let mainPower = "PW"
    private let zoneOnCmd = ["ZM", "Z2", "Z3", "Z4"]
    private let zoneMute = "MU"
    private let zoneLevelCmd = ["MV", "Z2", "Z3", "Z4"]
    private let zoneSourceCmd = ["SI", "Z2", "Z3", "Z4"]
    private let sourceParameter = ["DVD", "TUNER", "TV"]

    private let query = "?"
    private let cr = "\r"
    
    // Query current state of view
    func queryState(zoneID: Int) {
        if zoneID == 0 {
            // zone 0 does not have a convenience command to receive all data
            power(zoneID: zoneID)
            Thread.sleep(forTimeInterval: 0.01)
            
            mute(zoneID: zoneID)
            Thread.sleep(forTimeInterval: 0.01)

            source(zoneID: zoneID)
            Thread.sleep(forTimeInterval: 0.01)

            volume(zoneID: zoneID)
        }  else {
            request = zoneOnCmd[zoneID] + query + cr
        }
    }
    
    // Parsing functionality
    func parse(reply: String, data: DataStore) {
        // Multiple commands may return separated by cr
        let commands = reply.split(separator: "\r")
        for command in commands {
            // The reply is required to have at least 4 characters.
            if command.count < 4 {
                break
            }

            // extract the primary command & check for secondary
            var cmd = String(command.prefix(2))
            var parameter = command.dropFirst(2)

            // Map the command to the zone
            let zoneID = zoneOnCmd.firstIndex(of: cmd) ?? 0

            if parameter.hasPrefix(zoneMute)  {
                // Drill down to extend the command if not the main zone
                cmd = String(parameter.prefix(2))
                parameter = parameter.dropFirst(2)
            }
            
            // Process and map commands onto the data store
            if let _ = zoneOnCmd.firstIndex(of: cmd) {
                // if the cmd can be found in the list of zone on commands
                data.controls[zoneID].powerOn = (parameter == "ON")
            } else if cmd == zoneMute {
                // if the cmd is to mute
                data.controls[zoneID].speakersLive = (parameter == "OFF")
            } else if let _ = sourceParameter.firstIndex(of: String(parameter)) {
                // if the parameter can be found in the list of source inputs
                data.controls[zoneID].sourceInput = SourceInput(rawValue: String(parameter)) ?? SourceInput.mediadevice
            } else if let _ = zoneLevelCmd.firstIndex(of: cmd), let _ = Int(parameter) {
                // if the level command can be found in teh list of level commands & the parameter is a number
                data.controls[zoneID].level = (parameter as NSString).floatValue
            }
                
            print("Parsed data for zone \(zoneID) "  + cmd + " " + parameter)
        }
    }

    // Freeform Command
    func generic(event: String) {
        request = event + cr
    }

    // Master Unit Specific Command
    func standby(masterOn: Bool? = nil) {
        let command = mainPower

        if let masterOn = masterOn {
            let code = (masterOn) ? "ON" : "STANDBY"
            
            request = command + code + cr
        } else {
            request = command + query + cr
        }
    }
    
    // Zone Specific Commands
    func power(zoneID: Int, power: Bool? = nil) {
        let command = zoneOnCmd[zoneID]

        if let power = power {
            let code = (power) ? "ON" : "OFF"
            
            request = command + code + cr
        } else {
            request = command + query + cr
        }
    }

    func mute(zoneID: Int, live: Bool? = nil) {
        let command = (zoneID == 0) ? zoneMute : "Z" + "\(zoneID)" + zoneMute
        
        if let live = live {
            let code = (live ? "OFF" : "ON")
            
            request = command + code + cr
        } else {
            request = command + query + cr
        }
    }
    
    func volume(zoneID: Int, level: Int? = nil) {
        let command = zoneLevelCmd[zoneID]
        
        if let level = level {
            let code = "\(level)"
            
            request = command + code + cr
        } else {
            request = command + query + cr
        }
    }
    
    func source(zoneID: Int, input: SourceInput? = nil) {
        let command = zoneSourceCmd[zoneID]
        
        if let input = input {
            let code = input.rawValue
            
            request = command + code + cr
        } else {
            request = command + query + cr
        }
    }
}
