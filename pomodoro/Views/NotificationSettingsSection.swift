//
//  NotificationSettingsSection.swift
//  pomodoro
//

import SwiftUI
import AppKit

struct NotificationSettingsSection: View {
    @StateObject private var settings = NotificationSettings.shared

    var body: some View {
        Section("Sound Settings") {
            Toggle("Enable Sound", isOn: $settings.soundEnabled)

            if settings.soundEnabled {
                Toggle("Silent Mode", isOn: $settings.silentMode)
                    .help("When enabled, notifications will be sent without sound")

                Picker("Sound Type", selection: $settings.soundType) {
                    ForEach(SoundType.allCases) { soundType in
                        Text(soundType.rawValue).tag(soundType)
                    }
                }

                Button("Test Sound") {
                    testSound()
                }
                .disabled(settings.silentMode)
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

    private func testSound() {
        guard settings.shouldPlaySound else { return }

        let soundName = settings.soundType.systemSoundName
        
        if let soundName = soundName {
            // Try to load and play the system sound
            if let sound = NSSound(named: soundName) {
                sound.play()
            } else {
                // If the sound is not found, try alternative names or fallback to beep
                let alternativeNames = getAlternativeSoundNames(for: soundName)
                var played = false
                
                for altName in alternativeNames {
                    if let sound = NSSound(named: altName) {
                        sound.play()
                        played = true
                        break
                    }
                }
                
                if !played {
                    NSSound.beep()
                }
            }
        } else {
            // Default sound - use beep
            NSSound.beep()
        }
    }
    
    private func getAlternativeSoundNames(for soundName: String) -> [String] {
        // Map common sound names to their alternative names in macOS
        switch soundName {
        case "Bell":
            return ["Basso", "Bell"]
        case "Chime":
            return ["Tink", "Chime"]
        case "Note":
            return ["Morse", "Note"]
        case "Submerge":
            return ["Submarine", "Submerge"]
        default:
            return [soundName]
        }
    }
}
