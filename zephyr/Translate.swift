//
//  Translate.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 2/4/21.
//

import Foundation

class Translate :NSObject {
    
    private let query = "?"
    private let cr = "\r"

    func standby(masterOn: Bool? = nil) -> String {
        let command = "PW"

        if let masterOn = masterOn {
            let code = (masterOn) ? "ON" : "STANDBY"
            
            return command + code + cr
        }
                
        return command + query + cr
    }
    
    func power(zoneID: Int, power: Bool? = nil) -> String {
        let command = (zoneID == 1) ? "ZM" : "Z" + "\(zoneID)"

        if let power = power {
            let code = (power) ? "ON" : "OFF"
            
            return command + code + cr
        }
        
        return command + query + cr
    }

    func mute(zoneID: Int, live: Bool? = nil) -> String {
        let command = (zoneID == 1) ? "" : "Z" + "\(zoneID)"
        
        if let live = live {
            let code = "MU" + (live ? "ON" : "OFF")
            
            return command + code + cr
        }

        return command + query + cr
    }
    
    func volume(zoneID: Int, level: Int? = nil) -> String {
        let command = (zoneID == 1) ? "MV" : "Z" + "\(zoneID)"
        
        if let level = level {
            let code = "\(level)"
            
            return command + code + cr
        }

        return command + query + cr
    }
    
    func source(zoneID: Int, input: SourceInput? = nil) -> String {
        let command = (zoneID == 1) ? "SI" : "Z" + "\(zoneID)"
        
        if let input = input {
            let code = input.rawValue
            
            return command + code + cr
        }

        return command + query + cr
    }
}
