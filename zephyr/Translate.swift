//
//  Translate.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 2/4/21.
//

import SwiftUI

/*
 Translation layer that converts the control states into a string suitable
 for transmission to the AVR.  The strings are unique to Denon AVR-5805.
 
 Any call into the class will construct and deposit the string into "request"
 which is published to the application for network transmission.  The class
 will also parse any "reply" from the AVR and set the UI state appropriately.
 
 The protocol is a 2 or 4 character "command" followed by a parameter and a
 carriage return "cr", e.g. "SIDVD\r".  In order to query the state of a control,
 replace the parameter with the "query" character, e.g. "MU?\r"
 */
class Translate: ObservableObject {
    @Published private(set) var request = String()
    
    // Command codes.
    private let mainPower = "PW"
    private let zoneOnCmd = ["ZM", "Z2", "Z3", "Z4"]
    private let zoneMute = "MU"
    private let zoneLevelCmd = ["MV", "Z2", "Z3", "Z4"]
    private let zoneSourceCmd = ["SI", "Z2", "Z3", "Z4"]
    private let sourceParameter = ["DVD", "TUNER", "TV"]
    private let tunerFrequency = "TF"

    private let query = "?"
    private let cr = "\r"
    
    // AVR response time in milliseconds
    private let responseTime = 200
    
    // Query current state of view
    func queryState(zoneID: Int) {
        var dT = responseTime
        if zoneID == 0 {
            // zone 0 does not have a convenience command to receive all data, e.g. Z1?
            // Add a small delay between calls to ensure that the receiver has time to reply
            power(zoneID: zoneID)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(dT)) {
                self.mute(zoneID: zoneID)
                dT += dT
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(dT)) {
                self.source(zoneID: zoneID)
                dT += dT
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(dT)) {
                self.volume(zoneID: zoneID)
                dT += dT
            }
        }  else {
            request = zoneOnCmd[zoneID] + query + cr
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(dT)) {
            self.tunerDirectDial()
            dT += dT
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
                // if the level command can be found in the list of level commands & the parameter is a number
                data.controls[zoneID].level = (parameter as NSString).floatValue
            } else if cmd == tunerFrequency {
                // if the tuner command can be found in the list
                let am = (parameter.prefix(1) == "0") ? String(parameter.dropFirst().prefix(3)) : String(parameter.prefix(4))
                let fm = String(parameter.dropFirst().prefix(3) + "." + parameter.dropFirst(4).dropLast())
                data.tunerFrequncy = (parameter > "050000") ? am : fm
            } else {
                print("Command Not Found")
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
    
    func tunerDirectDial(frequency: String? = nil)
    {
        let command = tunerFrequency
                
        if let frequency = frequency {
            if (frequency > "050000") {
                request = "TMAM"
            } else {
                request = "TMFM"
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(responseTime)) {
                let code = frequency.replacingOccurrences(of: ".", with: "") + "00"
                self.request = self.tunerFrequency + code + self.cr
            }
        } else {
            request = command + query + cr
        }
        
    }
    
    func tunerChangeUp(scan: Bool) {
        let cmd = "TM"
        let code = scan ? "AUTO" : "MANUAL"
        
        request = cmd + code + cr
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(responseTime)) {
            self.request = self.tunerFrequency + "UP" + self.cr
        }
    }
    
    func tunerChangeDown(scan: Bool) {
        let cmd = "TM"
        let code = scan ? "AUTO" : "MANUAL"
        
        request = cmd + code + cr
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(responseTime)) {
            self.request = self.tunerFrequency + "DOWN" + self.cr
        }
    }
    
    func tunerPreset(preset: Int) {
        let command = "TP"
        let code = "A" + String(preset)
        
        request = command + code + cr
    }
}
