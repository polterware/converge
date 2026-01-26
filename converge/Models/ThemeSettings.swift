//
//  ThemeSettings.swift
//  pomodoro
//

import SwiftUI
import Combine
import AppKit

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

@MainActor
final class ThemeSettings: ObservableObject {
    @Published var selectedTheme: AppTheme {
        didSet {
            save()
            // Schedule all updates asynchronously to avoid publishing during view updates
            Task { @MainActor in
                self.updateSystemThemeObserver()
                self.scheduleThemeUpdate()
                // If not system theme, update immediately
                if self.selectedTheme != .system {
                    self.updateCurrentColorSchemeSync()
                }
            }
        }
    }
    
    @Published private var systemColorScheme: ColorScheme? = nil
    
    @Published var currentColorScheme: ColorScheme? = nil
    
    private var appearanceTimer: Timer?
    
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
        scheduleThemeUpdate()
    }
    
    deinit {
        appearanceTimer?.invalidate()
    }
    
    /// Schedules @Published updates on the next run loop to avoid "Publishing changes from within view updates".
    /// Marked nonisolated so the Timer closure can call it; actual updates run on main via assumeIsolated.
    private nonisolated func scheduleThemeUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            MainActor.assumeIsolated {
                self.updateSystemColorScheme()
            }
        }
    }
    
    private func updateSystemThemeObserver() {
        appearanceTimer?.invalidate()
        appearanceTimer = nil
        
        guard selectedTheme == .system else { return }
        
        appearanceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.scheduleThemeUpdate()
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
