//
//  SettingsView.swift
//  pomodoro
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: PomodoroSettings
    
    @State private var workDuration: Int
    @State private var shortBreakDuration: Int
    @State private var longBreakDuration: Int
    @State private var pomodorosUntilLongBreak: Int
    @State private var showVisualSettings = false
    
    init() {
        // Initialize with default values, will be updated from environmentObject
        _workDuration = State(initialValue: 25)
        _shortBreakDuration = State(initialValue: 5)
        _longBreakDuration = State(initialValue: 15)
        _pomodorosUntilLongBreak = State(initialValue: 4)
    }
    
    var body: some View {
        Form {
            Section("Timer Settings") {
                DurationRow(
                    label: "Work Duration",
                    value: $workDuration,
                    range: 1...120,
                    unit: "min"
                )
                
                DurationRow(
                    label: "Short Break Duration",
                    value: $shortBreakDuration,
                    range: 1...60,
                    unit: "min"
                )
                
                DurationRow(
                    label: "Long Break Duration",
                    value: $longBreakDuration,
                    range: 1...120,
                    unit: "min"
                )
                
                DurationRow(
                    label: "Pomodoros Until Long Break",
                    value: $pomodorosUntilLongBreak,
                    range: 1...20,
                    unit: "count"
                )
                
                Button {
                    saveSettings()
                } label: {
                    HStack {
                        Spacer()
                        Text("Save")
                        Spacer()
                    }
                }
            }
            
            Section("Visual Settings") {
                Button {
                    showVisualSettings = true
                } label: {
                    HStack {
                        Text("Appearance")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }

            NotificationSettingsSection()

            Section {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .onAppear {
            loadCurrentSettings()
        }
        .sheet(isPresented: $showVisualSettings) {
            NavigationStack {
                VisualSettingsView()
            }
        }
    }
    
    private func loadCurrentSettings() {
        workDuration = settings.workDurationMinutes
        shortBreakDuration = settings.shortBreakDurationMinutes
        longBreakDuration = settings.longBreakDurationMinutes
        pomodorosUntilLongBreak = settings.pomodorosUntilLongBreak
    }
    
    private func saveSettings() {
        settings.workDurationMinutes = workDuration
        settings.shortBreakDurationMinutes = shortBreakDuration
        settings.longBreakDurationMinutes = longBreakDuration
        settings.pomodorosUntilLongBreak = pomodorosUntilLongBreak
    }
    
    private func resetToDefaults() {
        settings.resetToDefaults()
        loadCurrentSettings()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(PomodoroSettings())
        }
    }
}
