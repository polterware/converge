//
//  convergeApp.swift
//  converge
//
//  Created by Erick Barcelos on 25/01/26.
//

import SwiftUI
import AppKit

struct WindowManagerSetupView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var pomodoroTimer: PomodoroTimer
    @EnvironmentObject private var pomodoroSettings: PomodoroSettings
    @EnvironmentObject private var themeSettings: ThemeSettings
    @EnvironmentObject private var statisticsStore: StatisticsStore
    
    var body: some View {
        TabView {
            PomodoroView()
                .tabItem {
                    Image(systemName: "stopwatch.fill")
                }
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                }
            SessionHistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                }
        }
        .tabViewStyle(.automatic)
        .overlay(alignment: .bottomTrailing) {
            CompactButton()
                .padding(16)
        }
        .preferredColorScheme(themeSettings.currentColorScheme)
        .onAppear {
            WindowManager.shared.setOpenWindowAction { id in
                NSApp.activate(ignoringOtherApps: true)
                
                let windowTitle = id == "main" ? "" : "Converge Settings"
                
                // Check if window already exists
                if let existingWindow = NSApp.windows.first(where: { window in
                    if id == "main" {
                        return window.canBecomeMain && window.isVisible
                    } else {
                        return window.isVisible && window.title == windowTitle
                    }
                }) {
                    existingWindow.makeKeyAndOrderFront(nil)
                    existingWindow.orderFrontRegardless()
                } else {
                    openWindow(id: id)
                }
            }
        }
    }
}

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .appSettings) {
            Button("Settings...") {
                WindowManager.shared.openSettingsWindow()
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}

@main
struct convergeApp: App {
    @StateObject private var pomodoroSettings: PomodoroSettings
    @StateObject private var pomodoroTimer: PomodoroTimer
    @StateObject private var themeSettings: ThemeSettings

    init() {
        let settings = PomodoroSettings()
        _pomodoroSettings = StateObject(wrappedValue: settings)
        _pomodoroTimer = StateObject(wrappedValue: PomodoroTimer(settings: settings))
        _themeSettings = StateObject(wrappedValue: ThemeSettings())
        
        Task {
            await NotificationManager.shared.requestAuthorization()
        }
    }
    

    var body: some Scene {
        WindowGroup(id: "main") {
            WindowManagerSetupView()
                .environmentObject(pomodoroTimer)
                .environmentObject(pomodoroSettings)
                .environmentObject(themeSettings)
                .environmentObject(StatisticsStore.shared)
        }
        .windowResizability(.automatic)
        .defaultSize(width: 400, height: 500)
        .commands {
            AppCommands()
        }

        Window("Converge Settings", id: "converge-settings") {
            NavigationStack {
                SettingsView()
            }
            .environmentObject(pomodoroTimer)
            .environmentObject(pomodoroSettings)
            .environmentObject(themeSettings)
            .environmentObject(StatisticsStore.shared)
            .preferredColorScheme(themeSettings.currentColorScheme)
        }
        .windowResizability(.automatic)
        .defaultSize(width: 480, height: 450)
        .commands {
            AppCommands()
        }

        MenuBarExtra {
            MenuBarContent()
                .environmentObject(pomodoroTimer)
                .environmentObject(pomodoroSettings)
                .environmentObject(themeSettings)
                .environmentObject(StatisticsStore.shared)
        } label: {
            Text(pomodoroTimer.formattedTime)
        }
        .commands {
            AppCommands()
        }
    }
}
