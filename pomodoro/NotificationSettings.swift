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
    
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("silentMode") var silentMode: Bool = false
    @AppStorage("soundType") private var soundTypeRawValue: String = SoundType.default.rawValue
    
    var soundType: SoundType {
        get {
            SoundType.allCases.first(where: { $0.rawValue == soundTypeRawValue }) ?? .default
        }
        set {
            soundTypeRawValue = newValue.rawValue
        }
    }
    
    private init() {}
    
    var shouldPlaySound: Bool {
        soundEnabled && !silentMode
    }
}
