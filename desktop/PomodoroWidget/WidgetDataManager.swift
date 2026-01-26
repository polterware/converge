//
//  WidgetDataManager.swift
//  PomodoroWidget
//
//  Created for Pomodoro Widget Extension
//

import Foundation

struct WidgetTimerData: Codable {
    let phase: String // "idle", "work", "break"
    let remainingSeconds: Int
    let isRunning: Bool
    let completedPomodoros: Int
    let lastUpdated: Date
    
    static let empty = WidgetTimerData(
        phase: "idle",
        remainingSeconds: 0,
        isRunning: false,
        completedPomodoros: 0,
        lastUpdated: Date()
    )
}

@MainActor
final class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let appGroupIdentifier = "group.polterware.pomodoro.shared"
    private let timerDataKey = "widgetTimerData"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    private init() {}
    
    func saveTimerData(_ data: WidgetTimerData) {
        guard let defaults = sharedDefaults else { return }
        
        do {
            let encoded = try JSONEncoder().encode(data)
            defaults.set(encoded, forKey: timerDataKey)
            defaults.synchronize()
        } catch {
            print("Failed to save widget timer data: \(error)")
        }
    }
    
    func loadTimerData() -> WidgetTimerData {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: timerDataKey) else {
            return .empty
        }
        
        do {
            let decoded = try JSONDecoder().decode(WidgetTimerData.self, from: data)
            return decoded
        } catch {
            print("Failed to load widget timer data: \(error)")
            return .empty
        }
    }
    
    func calculateRemainingSeconds(from data: WidgetTimerData) -> Int {
        guard data.isRunning else {
            return data.remainingSeconds
        }
        
        let elapsed = Date().timeIntervalSince(data.lastUpdated)
        let remaining = max(0, data.remainingSeconds - Int(elapsed))
        return remaining
    }
}
