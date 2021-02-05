//
//  Translate.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 2/4/21.
//

import Foundation

class Translate :NSObject {

    func standby(masterOn: Bool) -> String {
        let code = (masterOn) ? "ON" : "STANDBY"
        
        return "PW" + code + "\r"
    }

    
    func power(zoneID: Int, power: Bool) -> String {
        let zone = (zoneID == 1) ? "ZM" : "Z" + "\(zoneID)"
        let code = (power) ? "ON" : "OFF"
        
        return zone + code + "\r"
    }

    func mute(zoneID: Int, live: Bool) -> String {
        let zone = (zoneID == 1) ? "" : "Z" + "\(zoneID)"
        let code = "MU" + (live ? "ON" : "OFF")

        return zone + code + "\r"
    }
    
    func volume(zoneID: Int, level: Int) -> String {
        let zone = (zoneID == 1) ? "MV" : "Z" + "\(zoneID)"
        let code = String(level)

        return zone + code + "\r"
    }
    
    func source(zoneID: Int, input: SourceInput) -> String {
        let zone = (zoneID == 1) ? "SI" : "Z" + "\(zoneID)"
        let code = input.rawValue
                
        return zone + code + "\r"
    }
}
