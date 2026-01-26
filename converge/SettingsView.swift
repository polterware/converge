//
//  SettingsView.swift
//  pomodoro
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: PomodoroSettings
    @EnvironmentObject private var themeSettings: ThemeSettings
    
    @State private var workDuration: Int
    @State private var shortBreakDuration: Int
    @State private var longBreakDuration: Int
    @State private var pomodorosUntilLongBreak: Int
    @State private var showSaveFeedback = false
    @State private var showResetFeedback = false
    
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
                    unit: "min",
                    iconName: "clock.fill"
                )
                
                DurationRow(
                    label: "Short Break Duration",
                    value: $shortBreakDuration,
                    range: 1...60,
                    unit: "min",
                    iconName: "cup.and.saucer.fill"
                )
                
                DurationRow(
                    label: "Long Break Duration",
                    value: $longBreakDuration,
                    range: 1...120,
                    unit: "min",
                    iconName: "moon.fill"
                )
                
                DurationRow(
                    label: "Pomodoros Until Long Break",
                    value: $pomodorosUntilLongBreak,
                    range: 1...20,
                    unit: "count",
                    iconName: "number.circle.fill"
                )
                
                Button {
                    saveSettings()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save")
                        Spacer()
                    }
                }
            }
            
            Section("Visual Settings") {
                Label {
                    Picker("Appearance", selection: $themeSettings.selectedTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                } icon: {
                    Image(systemName: "paintbrush.fill")
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Choose how the app should appear. System follows your system settings.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            NotificationSettingsSection()

            Section {
                Button {
                    resetToDefaults()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset to Defaults")
                    }
                }
                .foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .overlay {
            VStack(spacing: 8) {
                SaveFeedbackView(isVisible: $showSaveFeedback)
                SaveFeedbackView(
                    isVisible: $showResetFeedback,
                    message: "Reset to Defaults",
                    iconName: "arrow.counterclockwise.circle.fill",
                    iconColor: .orange
                )
                Spacer()
            }
            .padding(.top, 20)
        }
        .onAppear {
            loadCurrentSettings()
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
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSaveFeedback = true
        }
    }
    
    private func resetToDefaults() {
        settings.resetToDefaults()
        themeSettings.resetToDefaults()
        NotificationSettings.shared.resetToDefaults()
        loadCurrentSettings()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showResetFeedback = true
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(PomodoroSettings())
                .environmentObject(ThemeSettings())
        }
    }
}
