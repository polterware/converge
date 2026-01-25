//
//  pomodoroApp.swift
//  pomodoro
//
//  Created by Erick Barcelos on 25/01/26.
//

import SwiftUI

@main
struct pomodoroApp: App {
    @StateObject private var pomodoroTimer = PomodoroTimer()

    init() {
        Task {
            await NotificationManager.shared.requestAuthorization()
        }
    }

    var body: some Scene {
        WindowGroup {
            PomodoroView()
                .environmentObject(pomodoroTimer)
        }
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarContent()
                .environmentObject(pomodoroTimer)
        } label: {
            Text(pomodoroTimer.formattedTime)
        }
    }
}
