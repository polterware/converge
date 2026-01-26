//
//  PomodoroSession.swift
//  pomodoro
//

import Foundation

struct PomodoroSession: Identifiable, Codable {
    let id: UUID
    let completedAt: Date
    let durationSeconds: Int

    init(id: UUID = UUID(), completedAt: Date = Date(), durationSeconds: Int) {
        self.id = id
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
    }
}
