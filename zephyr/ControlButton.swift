//
//  ControlButton.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 2/25/21.
//

import SwiftUI

struct ControlButton: View {
    @Binding var onState: Bool
    var text: String = ""
    var image: String = ""
    
    var body: some View {
        HStack {
            Button(action: {
                onState.toggle()
            }) {
                HStack {
                    Text(text)
                    Image(systemName: image)
                }
            }
        }
    }
}

struct ControlButton_Previews: PreviewProvider {
    static var previews: some View {
        ControlButton(onState: .constant(true), text: "Power", image: "power")
    }
}
