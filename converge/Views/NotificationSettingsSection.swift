//
//  NotificationSettingsSection.swift
//  pomodoro
//

import SwiftUI
import AppKit

struct NotificationSettingsSection: View {
    @StateObject private var settings = NotificationSettings.shared
    @State private var currentSound: NSSound?

    var body: some View {
        Section("Sound Settings") {
            Toggle("Enable Sound", isOn: $settings.soundEnabled)

            if settings.soundEnabled {
                Picker("Pomodoro Sound", selection: $settings.workSoundType) {
                    ForEach(SoundType.allCases) { soundType in
                        Text(soundType.rawValue).tag(soundType)
                    }
                }

                Button("Test Pomodoro Sound") {
                    testSound(soundType: settings.workSoundType)
                }

                Picker("Break Sound", selection: $settings.breakSoundType) {
                    ForEach(SoundType.allCases) { soundType in
                        Text(soundType.rawValue).tag(soundType)
                    }
                }

                Button("Test Break Sound") {
                    testSound(soundType: settings.breakSoundType)
                }
            }
        }

        Section {
            Text("Notifications will appear when:")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Label("Work session completes", systemImage: "checkmark.circle")
                Label("Break session completes", systemImage: "checkmark.circle")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private func testSound(soundType: SoundType) {
        guard settings.shouldPlaySound else { return }

        // Stop any currently playing sound
        currentSound?.stop()
        currentSound = nil

        if let soundName = soundType.systemSoundName {
            if let sound = NSSound(named: soundName) {
                currentSound = sound
                sound.play()
            } else {
                // Fallback to beep if sound not found
                NSSound.beep()
            }
        } else {
            // Default sound - use beep
            NSSound.beep()
        }
    }
}
