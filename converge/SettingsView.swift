//
//  SettingsView.swift
//  pomodoro
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: PomodoroSettings
    @EnvironmentObject private var themeSettings: ThemeSettings
    
    @State private var showResetFeedback = false
    
    var body: some View {
        Form {
            Section("Timer Settings") {
                DurationRow(
                    label: "Work Duration",
                    value: $settings.workDurationMinutes,
                    range: 1...120,
                    unit: "min",
                    iconName: "clock.fill"
                )
                
                DurationRow(
                    label: "Short Break Duration",
                    value: $settings.shortBreakDurationMinutes,
                    range: 1...60,
                    unit: "min",
                    iconName: "cup.and.saucer.fill"
                )
                
                DurationRow(
                    label: "Long Break Duration",
                    value: $settings.longBreakDurationMinutes,
                    range: 1...120,
                    unit: "min",
                    iconName: "moon.fill"
                )
                
                DurationRow(
                    label: "Pomodoros Until Long Break",
                    value: $settings.pomodorosUntilLongBreak,
                    range: 1...20,
                    unit: "count",
                    iconName: "number.circle.fill"
                )
                
                Toggle(isOn: $settings.autoContinue) {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Auto Continue")
                            Text("Automatically start next phase when current phase ends")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "arrow.clockwise")
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
    }
    
    private func resetToDefaults() {
        settings.resetToDefaults()
        themeSettings.resetToDefaults()
        NotificationSettings.shared.resetToDefaults()

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
