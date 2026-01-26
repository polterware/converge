//
//  StatisticsStore.swift
//  pomodoro
//

import Foundation
import Combine

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

@MainActor
final class StatisticsStore: ObservableObject {
    static let shared = StatisticsStore()

    private static let userDefaultsKey = "pomodoro_sessions"
    private let calendar = Calendar.current

    @Published private(set) var sessions: [PomodoroSession] = [] {
        didSet { save() }
    }

    var pomodorosToday: Int { pomodoroCount(day: Date()) }
    var pomodorosThisWeek: Int { pomodoroCount(weekOf: Date()) }
    var pomodorosThisMonth: Int { pomodoroCount(month: Date()) }

    private init() {
        load()
    }

    func recordCompletedPomodoro(durationSeconds: Int) {
        let session = PomodoroSession(completedAt: Date(), durationSeconds: durationSeconds)
        sessions.append(session)
    }

    func clearAll() {
        sessions = []
        UserDefaults.standard.removeObject(forKey: Self.userDefaultsKey)
    }

    func pomodoroCount(day: Date) -> Int {
        sessions.filter { calendar.isDate($0.completedAt, inSameDayAs: day) }.count
    }

    func pomodoroCount(weekOf date: Date) -> Int {
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start else { return 0 }
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? date
        return sessions.filter { $0.completedAt >= startOfWeek && $0.completedAt < endOfWeek }.count
    }

    func pomodoroCount(month: Date) -> Int {
        sessions.filter { calendar.isDate($0.completedAt, equalTo: month, toGranularity: .month) }.count
    }

    func recentSessions(limit: Int) -> [PomodoroSession] {
        Array(sessions.sorted { $0.completedAt > $1.completedAt }.prefix(limit))
    }

    func chartData(days: Int) -> [ChartDataPoint] {
        let end = calendar.startOfDay(for: Date())
        guard let start = calendar.date(byAdding: .day, value: -days, to: end) else { return [] }
        var result: [ChartDataPoint] = []
        var current = start
        while current <= end {
            let count = pomodoroCount(day: current)
            result.append(ChartDataPoint(date: current, count: count))
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return result
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey) else {
            sessions = []
            return
        }
        do {
            let decoded = try JSONDecoder().decode([PomodoroSession].self, from: data)
            sessions = decoded
        } catch {
            sessions = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        } catch {
            // ignore encode failure
        }
    }
}
