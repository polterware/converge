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
    @StateObject private var updateManager = UpdateManager.shared

    var body: some View {
        Group {
            Button {
                if timer.isRunning {
                    timer.pause()
                } else {
                    timer.start()
                }
            } label: {
                Label(timer.isRunning ? "Pause" : "Start", systemImage: timer.isRunning ? "pause.fill" : "play.fill")
            }

            Button {
                timer.reset()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }

            Divider()

            Text("Today: \(store.pomodorosToday) · Week: \(store.pomodorosThisWeek) · Month: \(store.pomodorosThisMonth)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                activateAndOpenWindow(id: "main")
            } label: {
                Label("Open Window", systemImage: "square.on.square")
            }

            Button {
                activateAndOpenWindow(id: "converge-settings")
            } label: {
                Label("Settings...", systemImage: "gearshape.fill")
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            Text("Version \(updateManager.fullVersionString)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                updateManager.checkForUpdates()
            } label: {
                Label("Check for Updates...", systemImage: "arrow.clockwise")
            }
            .disabled(!updateManager.canCheckForUpdates)

            Divider()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
            }
        }
        .onAppear {
            WindowManager.shared.setOpenWindowAction { id in
                activateAndOpenWindow(id: id)
            }
        }
    }

    private func activateAndOpenWindow(id: String) {
        NSApp.activate(ignoringOtherApps: true)
        
        // Map window IDs to titles for finding existing windows
        let windowTitles: [String: String] = [
            "main": "",
            "converge-settings": "Converge Settings"
        ]
        
        let targetTitle = windowTitles[id] ?? ""
        
        // Check if window already exists
        if let existingWindow = findExistingWindow(id: id, title: targetTitle) {
            // Window exists, just bring it to front
            existingWindow.makeKeyAndOrderFront(nil)
            existingWindow.orderFrontRegardless()
        } else {
            // Window doesn't exist, create new one
            openWindow(id: id)
        }
    }
    
    private func findExistingWindow(id: String, title: String) -> NSWindow? {
        if id == "main" {
            // For main window, find any visible window that can become main
            return NSApp.windows.first { window in
                window.canBecomeMain && window.isVisible
            }
        } else {
            // For other windows, find by title
            return NSApp.windows.first { window in
                window.isVisible && window.title == title
            }
        }
    }
}
