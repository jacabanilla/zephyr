//
//  DataStore.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 2/12/21.
//

import Foundation
import SwiftUI
import Combine

enum SourceInput: String, CaseIterable, Identifiable, Equatable {
    case dvd = "DVD"
    case mediadevice = "TV"
    case tuner = "TUNER"

    var id: String { self.rawValue }
    
    static func == (lhs: SourceInput, rhs: SourceInput) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

struct ControlData: Identifiable {
    var id = UUID()
    var powerOn: Bool
    var speakersLive: Bool
    var level: Float
    var sourceInput: SourceInput
}

let controlData = [
    ControlData(powerOn: false, speakersLive: false, level: 10.0, sourceInput: SourceInput.mediadevice),
    ControlData(powerOn: false, speakersLive: false, level: 10.0, sourceInput: SourceInput.mediadevice),
    ControlData(powerOn: false, speakersLive: false, level: 10.0, sourceInput: SourceInput.mediadevice),
    ControlData(powerOn: false, speakersLive: false, level: 10.0, sourceInput: SourceInput.mediadevice),
]

class DataStore: ObservableObject {
    @Published var isConnected = false
    @Published var mainPowerOn = false
    @Published var tunerFrequncy = "101.1"
    @Published var controls = controlData
    
    var myTxSubscriber: AnyCancellable?
    var myRxSubscriber: AnyCancellable?
}
