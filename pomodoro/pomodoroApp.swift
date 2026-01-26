//
//  pomodoroApp.swift
//  pomodoro
//
//  Created by Erick Barcelos on 25/01/26.
//

import SwiftUI

@main
struct pomodoroApp: App {
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
            TabView {
                PomodoroView()
                    .tabItem {
                        Image(systemName: "stopwatch.fill")
                        Text("Timer")
                    }
                StatisticsView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Statistics")
                    }
                SessionHistoryView()
                    .tabItem {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("History")
                    }
            }
            .tabViewStyle(.automatic)
            .environmentObject(pomodoroTimer)
            .environmentObject(pomodoroSettings)
            .environmentObject(themeSettings)
            .environmentObject(StatisticsStore.shared)
            .preferredColorScheme(themeSettings.currentColorScheme)
        }
        .windowResizability(.automatic)
        .defaultSize(width: 400, height: 500)

        Window("Pomodoro Settings", id: "pomodoro-settings") {
            NavigationStack {
                SettingsView()
            }
            .environmentObject(pomodoroTimer)
            .environmentObject(pomodoroSettings)
            .environmentObject(themeSettings)
            .environmentObject(StatisticsStore.shared)
        }
        .windowResizability(.automatic)
        .defaultSize(width: 420, height: 560)

        MenuBarExtra {
            MenuBarContent()
                .environmentObject(pomodoroTimer)
                .environmentObject(pomodoroSettings)
                .environmentObject(themeSettings)
                .environmentObject(StatisticsStore.shared)
        } label: {
            Text(pomodoroTimer.formattedTime)
        }
    }
}
