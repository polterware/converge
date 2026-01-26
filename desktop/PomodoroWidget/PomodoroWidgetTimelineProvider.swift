//
//  PomodoroWidgetTimelineProvider.swift
//  PomodoroWidget
//
//  Created for Pomodoro Widget Extension
//

import WidgetKit
import SwiftUI

struct PomodoroWidgetTimelineProvider: TimelineProvider {
    typealias Entry = PomodoroWidgetEntry
    
    func placeholder(in context: Context) -> PomodoroWidgetEntry {
        PomodoroWidgetEntry(
            date: Date(),
            phase: .idle,
            remainingSeconds: 25 * 60,
            isRunning: false,
            completedPomodoros: 0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PomodoroWidgetEntry) -> Void) {
        let data = WidgetDataManager.shared.loadTimerData()
        let remaining = WidgetDataManager.shared.calculateRemainingSeconds(from: data)
        
        let phase: PomodoroPhase = {
            switch data.phase {
            case "work": return .work
            case "break": return .break
            default: return .idle
            }
        }()
        
        let entry = PomodoroWidgetEntry(
            date: Date(),
            phase: phase,
            remainingSeconds: remaining,
            isRunning: data.isRunning,
            completedPomodoros: data.completedPomodoros
        )
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PomodoroWidgetEntry>) -> Void) {
        let data = WidgetDataManager.shared.loadTimerData()
        let remaining = WidgetDataManager.shared.calculateRemainingSeconds(from: data)
        
        let phase: PomodoroPhase = {
            switch data.phase {
            case "work": return .work
            case "break": return .break
            default: return .idle
            }
        }()
        
        let currentEntry = PomodoroWidgetEntry(
            date: Date(),
            phase: phase,
            remainingSeconds: remaining,
            isRunning: data.isRunning,
            completedPomodoros: data.completedPomodoros
        )
        
        var entries: [PomodoroWidgetEntry] = [currentEntry]
        
        if data.isRunning && remaining > 0 {
            let endDate = Date().addingTimeInterval(TimeInterval(remaining))
            
            let endEntry = PomodoroWidgetEntry(
                date: endDate,
                phase: phase,
                remainingSeconds: 0,
                isRunning: false,
                completedPomodoros: data.completedPomodoros
            )
            entries.append(endEntry)
            
            let nextUpdateDate = Date().addingTimeInterval(1.0)
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
            completion(timeline)
        } else {
            let nextUpdateDate = Date().addingTimeInterval(60.0)
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
}

struct PomodoroWidgetEntry: TimelineEntry {
    let date: Date
    let phase: PomodoroPhase
    let remainingSeconds: Int
    let isRunning: Bool
    let completedPomodoros: Int
    
    var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    var progress: Double {
        let totalSeconds: Int
        switch phase {
        case .work:
            totalSeconds = 25 * 60
        case .break:
            totalSeconds = 5 * 60
        case .idle:
            return 0.0
        }
        guard totalSeconds > 0 else { return 0.0 }
        let elapsed = totalSeconds - remainingSeconds
        return max(0.0, min(1.0, Double(elapsed) / Double(totalSeconds)))
    }
}

enum PomodoroPhase {
    case idle
    case work
    case `break`
    
    var displayName: String {
        switch self {
        case .idle: return "Idle"
        case .work: return "Work"
        case .break: return "Break"
        }
    }
    
    var iconName: String {
        switch self {
        case .idle: return "timer"
        case .work: return "flame.fill"
        case .break: return "moon.fill"
        }
    }
}
