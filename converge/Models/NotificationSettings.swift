//
//  NotificationSettings.swift
//  pomodoro
//

import Foundation
import SwiftUI
import Combine

enum SoundType: String, CaseIterable, Identifiable {
    case `default` = "Default"
    case bell = "Bell"
    case chime = "Chime"
    case glass = "Glass"
    case hero = "Hero"
    case note = "Note"
    case ping = "Ping"
    case pop = "Pop"
    case purr = "Purr"
    case sosumi = "Sosumi"
    case submerge = "Submerge"
    case tink = "Tink"
    
    var id: String { rawValue }
    
    var systemSoundName: String? {
        switch self {
        case .default:
            return nil
        case .bell:
            return "Basso"
        case .chime:
            return "Tink"
        case .glass:
            return "Glass"
        case .hero:
            return "Hero"
        case .note:
            return "Morse"
        case .ping:
            return "Ping"
        case .pop:
            return "Pop"
        case .purr:
            return "Purr"
        case .sosumi:
            return "Sosumi"
        case .submerge:
            return "Submarine"
        case .tink:
            return "Tink"
        }
    }
}

@MainActor
final class NotificationSettings: ObservableObject {
    static let shared = NotificationSettings()
    
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("soundType") private var soundTypeRawValue: String = SoundType.default.rawValue
    @AppStorage("workSoundType") private var workSoundTypeRawValue: String = SoundType.glass.rawValue
    @AppStorage("breakSoundType") private var breakSoundTypeRawValue: String = SoundType.bell.rawValue
    
    var soundType: SoundType {
        get {
            SoundType.allCases.first(where: { $0.rawValue == soundTypeRawValue }) ?? .default
        }
        set {
            soundTypeRawValue = newValue.rawValue
        }
    }
    
    var workSoundType: SoundType {
        get {
            SoundType.allCases.first(where: { $0.rawValue == workSoundTypeRawValue }) ?? .glass
        }
        set {
            workSoundTypeRawValue = newValue.rawValue
        }
    }
    
    var breakSoundType: SoundType {
        get {
            SoundType.allCases.first(where: { $0.rawValue == breakSoundTypeRawValue }) ?? .bell
        }
        set {
            breakSoundTypeRawValue = newValue.rawValue
        }
    }
    
    private init() {}

    func resetToDefaults() {
        objectWillChange.send()
        notificationsEnabled = true
        soundEnabled = true
        soundTypeRawValue = SoundType.default.rawValue
        workSoundTypeRawValue = SoundType.glass.rawValue
        breakSoundTypeRawValue = SoundType.bell.rawValue
    }

    var shouldPlaySound: Bool {
        soundEnabled
    }
}
