//
//  Modifiers.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 2/16/21.
//

import SwiftUI

struct ButtonModifier: ViewModifier {
    var onState: Bool = true
    
    func body(content: Content) -> some View {
        content
            .frame(width: 100, height: 50)
            .foregroundColor(Color.white)
            .background(onState ? Color.onColor : Color.offColor)
            .cornerRadius(15.0)
            .padding(25)
    }
}

struct TextFieldModifier: ViewModifier {
    var colorState: Bool = true
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 50)
            .multilineTextAlignment(.center)
            .disableAutocorrection(true)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .foregroundColor(colorState ? Color.offColor : Color.errorColor)
    }
}
