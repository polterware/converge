//
//  RoundedButtonStyle.swift
//  pomodoro
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    var luminance: Double {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        #elseif canImport(AppKit)
        let uiColor = NSColor(self)
        #endif
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        #if canImport(UIKit)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif canImport(AppKit)
        if let rgbColor = uiColor.usingColorSpace(.deviceRGB) {
            rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        #endif
        
        return 0.299 * Double(red) + 0.587 * Double(green) + 0.114 * Double(blue)
    }
    
    var contrastingForegroundColor: Color {
        luminance < 0.5 ? .white : .black
    }
}

struct RoundedBorderedProminentButtonStyle: ButtonStyle {
    var color: Color = .accentColor
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(color)
            )
            .foregroundColor(color.contrastingForegroundColor)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct RoundedBorderedButtonStyle: ButtonStyle {
    var color: Color = .primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(color, lineWidth: 1)
            )
            .foregroundColor(color)
            .contentShape(RoundedRectangle(cornerRadius: 24))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
