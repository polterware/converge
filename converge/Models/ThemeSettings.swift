//
//  ThemeSettings.swift
//  pomodoro
//

import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case light
    case dark
    case automatic
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .automatic: return "Automatic"
        }
    }
}

@MainActor
final class ThemeSettings: ObservableObject {
    @Published var selectedTheme: AppTheme {
        didSet {
            save()
        }
    }
    
    private enum Keys {
        static let selectedTheme = "selectedTheme"
    }
    
    private static let defaultTheme: AppTheme = .automatic
    
    init() {
        if let savedThemeRaw = UserDefaults.standard.string(forKey: Keys.selectedTheme),
           let savedTheme = AppTheme(rawValue: savedThemeRaw) {
            self.selectedTheme = savedTheme
        } else {
            self.selectedTheme = Self.defaultTheme
        }
    }
    
    private func save() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: Keys.selectedTheme)
    }

    func resetToDefaults() {
        selectedTheme = Self.defaultTheme
    }

    var currentColorScheme: ColorScheme? {
        switch selectedTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .automatic:
            return nil
        }
    }
}
