//
//  PomodoroSettings.swift
//  pomodoro
//

import Foundation
import Combine

@MainActor
final class PomodoroSettings: ObservableObject {
    // MARK: - Published Properties
    @Published var workDurationMinutes: Int {
        didSet {
            save()
        }
    }
    
    @Published var shortBreakDurationMinutes: Int {
        didSet {
            save()
        }
    }
    
    @Published var longBreakDurationMinutes: Int {
        didSet {
            save()
        }
    }
    
    @Published var pomodorosUntilLongBreak: Int {
        didSet {
            save()
        }
    }
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let workDurationMinutes = "workDurationMinutes"
        static let shortBreakDurationMinutes = "shortBreakDurationMinutes"
        static let longBreakDurationMinutes = "longBreakDurationMinutes"
        static let pomodorosUntilLongBreak = "pomodorosUntilLongBreak"
    }
    
    // MARK: - Default Values
    private static let defaultWorkDurationMinutes = 25
    private static let defaultShortBreakDurationMinutes = 5
    private static let defaultLongBreakDurationMinutes = 15
    private static let defaultPomodorosUntilLongBreak = 4
    
    // MARK: - Initialization
    init() {
        let defaults = UserDefaults.standard
        
        let workDuration = defaults.integer(forKey: Keys.workDurationMinutes)
        self.workDurationMinutes = workDuration == 0 ? Self.defaultWorkDurationMinutes : workDuration
        
        let shortBreakDuration = defaults.integer(forKey: Keys.shortBreakDurationMinutes)
        self.shortBreakDurationMinutes = shortBreakDuration == 0 ? Self.defaultShortBreakDurationMinutes : shortBreakDuration
        
        let longBreakDuration = defaults.integer(forKey: Keys.longBreakDurationMinutes)
        self.longBreakDurationMinutes = longBreakDuration == 0 ? Self.defaultLongBreakDurationMinutes : longBreakDuration
        
        let pomodorosUntilLongBreak = defaults.integer(forKey: Keys.pomodorosUntilLongBreak)
        self.pomodorosUntilLongBreak = pomodorosUntilLongBreak == 0 ? Self.defaultPomodorosUntilLongBreak : pomodorosUntilLongBreak
    }
    
    // MARK: - Persistence
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(workDurationMinutes, forKey: Keys.workDurationMinutes)
        defaults.set(shortBreakDurationMinutes, forKey: Keys.shortBreakDurationMinutes)
        defaults.set(longBreakDurationMinutes, forKey: Keys.longBreakDurationMinutes)
        defaults.set(pomodorosUntilLongBreak, forKey: Keys.pomodorosUntilLongBreak)
    }
    
    func resetToDefaults() {
        workDurationMinutes = Self.defaultWorkDurationMinutes
        shortBreakDurationMinutes = Self.defaultShortBreakDurationMinutes
        longBreakDurationMinutes = Self.defaultLongBreakDurationMinutes
        pomodorosUntilLongBreak = Self.defaultPomodorosUntilLongBreak
    }
    
    // MARK: - Computed Properties
    var workDurationSeconds: Int {
        workDurationMinutes * 60
    }
    
    var shortBreakDurationSeconds: Int {
        shortBreakDurationMinutes * 60
    }
    
    var longBreakDurationSeconds: Int {
        longBreakDurationMinutes * 60
    }
}
