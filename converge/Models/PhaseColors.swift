//
//  PhaseColors.swift
//  pomodoro
//

import SwiftUI

struct PhaseColors {
    let background: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    
    static func color(for phase: PomodoroPhase, colorScheme: ColorScheme = .light, isRunning: Bool = true) -> PhaseColors {
        // Se está em idle, sempre retorna cores neutras (não começou)
        if phase == .idle {
            return baseColor(for: .idle, colorScheme: colorScheme)
        }
        
        // Se está em work ou break e não está rodando, retorna cores pausadas
        if !isRunning {
            return pausedColors(for: phase, colorScheme: colorScheme)
        }
        
        // Caso contrário, retorna cores normais da fase (running)
        return baseColor(for: phase, colorScheme: colorScheme)
    }
    
    private static func baseColor(for phase: PomodoroPhase, colorScheme: ColorScheme) -> PhaseColors {
        switch phase {
        case .work:
            return PhaseColors(
                background: colorScheme == .dark
                    ? Color(red: 0.08, green: 0.12, blue: 0.18)
                    : Color(red: 0.95, green: 0.97, blue: 1.0),
                primary: colorScheme == .dark
                    ? Color(red: 0.45, green: 0.65, blue: 0.95)
                    : Color(red: 0.20, green: 0.40, blue: 0.75),
                secondary: colorScheme == .dark
                    ? Color(red: 0.30, green: 0.50, blue: 0.80)
                    : Color(red: 0.15, green: 0.30, blue: 0.60),
                accent: colorScheme == .dark
                    ? Color(red: 0.55, green: 0.72, blue: 1.0)
                    : Color(red: 0.30, green: 0.50, blue: 0.85)
            )
        case .break:
            return PhaseColors(
                background: colorScheme == .dark
                    ? Color(red: 0.07, green: 0.15, blue: 0.14)
                    : Color(red: 0.94, green: 0.98, blue: 0.97),
                primary: colorScheme == .dark
                    ? Color(red: 0.40, green: 0.85, blue: 0.78)
                    : Color(red: 0.20, green: 0.65, blue: 0.60),
                secondary: colorScheme == .dark
                    ? Color(red: 0.30, green: 0.70, blue: 0.65)
                    : Color(red: 0.15, green: 0.55, blue: 0.50),
                accent: colorScheme == .dark
                    ? Color(red: 0.50, green: 0.90, blue: 0.82)
                    : Color(red: 0.30, green: 0.75, blue: 0.70)
            )
        case .idle:
            return PhaseColors(
                background: colorScheme == .dark
                    ? Color(red: 0.1, green: 0.1, blue: 0.1)
                    : Color(red: 0.98, green: 0.98, blue: 0.98),
                primary: colorScheme == .dark
                    ? Color(red: 0.7, green: 0.7, blue: 0.7)
                    : Color(red: 0.3, green: 0.3, blue: 0.3),
                secondary: colorScheme == .dark
                    ? Color(red: 0.5, green: 0.5, blue: 0.5)
                    : Color(red: 0.5, green: 0.5, blue: 0.5),
                accent: colorScheme == .dark
                    ? Color(red: 0.8, green: 0.8, blue: 0.8)
                    : Color(red: 0.4, green: 0.4, blue: 0.4)
            )
        }
    }
    
    private static func pausedColors(for phase: PomodoroPhase, colorScheme: ColorScheme) -> PhaseColors {
        // Cores pausadas mantêm a identidade da fase mas com desaturação e escurecimento
        switch phase {
        case .work:
            // Work pausado: azul desaturado/escurecido
            return PhaseColors(
                background: colorScheme == .dark
                    ? Color(red: 0.06, green: 0.10, blue: 0.15)
                    : Color(red: 0.92, green: 0.94, blue: 0.98),
                primary: colorScheme == .dark
                    ? Color(red: 0.35, green: 0.50, blue: 0.75)
                    : Color(red: 0.35, green: 0.45, blue: 0.65),
                secondary: colorScheme == .dark
                    ? Color(red: 0.25, green: 0.42, blue: 0.68)
                    : Color(red: 0.25, green: 0.35, blue: 0.55),
                accent: colorScheme == .dark
                    ? Color(red: 0.40, green: 0.58, blue: 0.82)
                    : Color(red: 0.40, green: 0.50, blue: 0.72)
            )
        case .break:
            // Break pausado: teal desaturado/escurecido
            return PhaseColors(
                background: colorScheme == .dark
                    ? Color(red: 0.05, green: 0.12, blue: 0.11)
                    : Color(red: 0.90, green: 0.95, blue: 0.94),
                primary: colorScheme == .dark
                    ? Color(red: 0.32, green: 0.70, blue: 0.65)
                    : Color(red: 0.35, green: 0.55, blue: 0.52),
                secondary: colorScheme == .dark
                    ? Color(red: 0.25, green: 0.58, blue: 0.54)
                    : Color(red: 0.28, green: 0.48, blue: 0.45),
                accent: colorScheme == .dark
                    ? Color(red: 0.38, green: 0.75, blue: 0.70)
                    : Color(red: 0.40, green: 0.62, blue: 0.58)
            )
        case .idle:
            // Idle nunca deve chegar aqui, mas retorna cores neutras por segurança
            return baseColor(for: .idle, colorScheme: colorScheme)
        }
    }
}
