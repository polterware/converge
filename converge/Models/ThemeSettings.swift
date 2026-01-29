//
//  ThemeSettings.swift
//  pomodoro
//

import SwiftUI
import AppKit
import Combine

enum AppTheme: String, CaseIterable {
    case light
    case dark
    case system
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

final class ThemeSettings: ObservableObject {
    @Published var selectedTheme: AppTheme {
        didSet {
            save()
            Task { @MainActor in
                self.updateSystemThemeObserver()
                if self.selectedTheme == .system {
                    self.updateSystemColorScheme()
                } else {
                    self.updateCurrentColorSchemeSync()
                }
            }
        }
    }
    
    @Published private(set) var systemColorScheme: ColorScheme? = nil
    
    @Published var currentColorScheme: ColorScheme? = nil
    
    private var appearanceObserver: NSKeyValueObservation?
    
    private enum Keys {
        static let selectedTheme = "selectedTheme"
    }
    
    private static let defaultTheme: AppTheme = .system
    
    init() {
        // Migração: converter "automatic" antigo para "system"
        if let savedThemeRaw = UserDefaults.standard.string(forKey: Keys.selectedTheme) {
            if savedThemeRaw == "automatic" {
                self.selectedTheme = .system
                save()
            } else if let savedTheme = AppTheme(rawValue: savedThemeRaw) {
                self.selectedTheme = savedTheme
            } else {
                self.selectedTheme = Self.defaultTheme
            }
        } else {
            self.selectedTheme = Self.defaultTheme
        }
        
        // Initialize currentColorScheme based on selected theme
        if selectedTheme == .system {
            let appearance = NSApp.effectiveAppearance
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            systemColorScheme = isDark ? .dark : .light
            currentColorScheme = systemColorScheme
        } else {
            currentColorScheme = selectedTheme == .light ? .light : .dark
        }
        
        updateSystemThemeObserver()
    }
    
    deinit {
        appearanceObserver?.invalidate()
    }
    
    private func updateSystemThemeObserver() {
        appearanceObserver?.invalidate()
        appearanceObserver = nil
        
        guard selectedTheme == .system else { return }
        
        appearanceObserver = NSApp.observe(\.effectiveAppearance) { [weak self] _, _ in
            guard let settings = self else { return }
            Task { @MainActor in
                settings.updateSystemColorScheme()
            }
        }
    }
    
    private func updateSystemColorScheme() {
        guard selectedTheme == .system else { return }
        
        let appearance = NSApp.effectiveAppearance
        let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let newSystemColorScheme = isDark ? ColorScheme.dark : ColorScheme.light
        
        // Schedule updates asynchronously to avoid publishing during view updates
        Task { @MainActor in
            self.systemColorScheme = newSystemColorScheme
            if self.selectedTheme == .system {
                self.currentColorScheme = newSystemColorScheme
            }
        }
    }
    
    private func updateCurrentColorSchemeSync() {
        switch selectedTheme {
        case .light:
            currentColorScheme = .light
        case .dark:
            currentColorScheme = .dark
        case .system:
            currentColorScheme = systemColorScheme
        }
    }
    
    private func save() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: Keys.selectedTheme)
    }

    func resetToDefaults() {
        selectedTheme = Self.defaultTheme
    }
}
