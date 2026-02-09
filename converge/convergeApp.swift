//
//  convergeApp.swift
//  converge
//
//  Created by Erick Barcelos on 25/01/26.
//

import SwiftUI
import AppKit

struct WindowManagerSetupView: View {
    private enum MainTab: Hashable {
        case pomodoro
        case statistics
        case history
    }

    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var pomodoroTimer: PomodoroTimer
    @EnvironmentObject private var pomodoroSettings: PomodoroSettings
    @EnvironmentObject private var themeSettings: ThemeSettings
    @EnvironmentObject private var statisticsStore: StatisticsStore
    @Environment(\.colorScheme) private var systemColorScheme
    @StateObject private var windowObserver = WindowObserver()
    @AppStorage("hasSeenWelcomeModal") private var hasSeenWelcomeModal = false
    @State private var showWelcomeModal = false
    @State private var selectedTab: MainTab = .pomodoro

    var body: some View {
        ZStack {
            GlassBackground(
                tint: phaseColors.background,
                tintOpacity: 0.85,
                isFullScreen: windowObserver.isFullScreen
            )
                .animation(.easeInOut(duration: 0.5), value: pomodoroTimer.phase)
                .animation(.easeInOut(duration: 0.5), value: pomodoroTimer.isRunning)
                .animation(.easeInOut(duration: 0.3), value: windowObserver.isFullScreen)

            ToolbarBackgroundHider(isFullScreen: windowObserver.isFullScreen)

            TabView(selection: $selectedTab) {
                PomodoroView(isActive: selectedTab == .pomodoro)
                    .tabItem {
                        Image(systemName: "stopwatch.fill")
                    }
                    .tag(MainTab.pomodoro)
                StatisticsView(isActive: selectedTab == .statistics)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                    }
                    .tag(MainTab.statistics)
                SessionHistoryView(isActive: selectedTab == .history)
                    .tabItem {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                    .tag(MainTab.history)
            }
            .tabViewStyle(.automatic)
            .toolbarBackground(.hidden, for: .windowToolbar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SettingsToolbarButton {
                        WindowManager.shared.openSettingsWindow()
                    }
                }
            }
            .overlay(alignment: .bottom) {
                HStack {
                    FullScreenButton()
                    Spacer()
                    CompactButton()
                }
                .padding(16)
            }
        }
        .preferredColorScheme(themeSettings.currentColorScheme)
        .sheet(isPresented: $showWelcomeModal) {
            WelcomeModalView(onDismiss: {
                hasSeenWelcomeModal = true
                showWelcomeModal = false
            })
            .environmentObject(themeSettings)
            .preferredColorScheme(themeSettings.currentColorScheme)
        }
        .onAppear {
            if !hasSeenWelcomeModal {
                showWelcomeModal = true
            }
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

    private var effectiveColorScheme: ColorScheme {
        themeSettings.currentColorScheme ?? systemColorScheme
    }

    private var phaseColors: PhaseColors {
        PhaseColors.color(
            for: pomodoroTimer.phase,
            colorScheme: effectiveColorScheme,
            isRunning: pomodoroTimer.isRunning
        )
    }
}

struct AppCommands: Commands {
    @ObservedObject private var updateManager = UpdateManager.shared

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button("Check for Updates…") {
                updateManager.checkForUpdates()
            }
            .disabled(!updateManager.canCheckForUpdates)
        }

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
    @StateObject private var themeSettings = ThemeSettings()
    @ObservedObject private var updateManager = UpdateManager.shared

    init() {
        let settings = PomodoroSettings()
        _pomodoroSettings = StateObject(wrappedValue: settings)
        _pomodoroTimer = StateObject(wrappedValue: PomodoroTimer(settings: settings))
        
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
                .glassWindow()
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
            .glassWindow()
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
