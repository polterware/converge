//
//  MenuBarContent.swift
//  pomodoro
//

import SwiftUI
import AppKit

struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var timer: PomodoroTimer
    @EnvironmentObject private var store: StatisticsStore

    var body: some View {
        Group {
            Button(timer.isRunning ? "Pause" : "Start") {
                if timer.isRunning {
                    timer.pause()
                } else {
                    timer.start()
                }
            }

            Button("Reset") {
                timer.reset()
            }

            Divider()

            Text("Today: \(store.pomodorosToday) · Week: \(store.pomodorosThisWeek) · Month: \(store.pomodorosThisMonth)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Open Window") {
                activateAndOpenWindow(id: "main")
            }

            Button("Pomodoro Settings...") {
                activateAndOpenWindow(id: "pomodoro-settings")
            }

            Button("Notification Settings...") {
                activateAndOpenWindow(id: "notification-settings")
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    private func activateAndOpenWindow(id: String) {
        NSApp.activate(ignoringOtherApps: true)
        openWindow(id: id)
    }
}
