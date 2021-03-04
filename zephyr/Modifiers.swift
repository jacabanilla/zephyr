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
            .multilineTextAlignment(.center)
            .disableAutocorrection(true)
            .foregroundColor(colorState ? Color.textColor : Color.errorColor)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct SceneModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.all, 25)
            .background(Color.backgroundColor)
            .edgesIgnoringSafeArea(.all)
    }
}
