//
//  CompactWindowService.swift
//  pomodoro
//

import AppKit

enum CompactWindowService {
    static let compactWidth: CGFloat = 400
    static let compactHeight: CGFloat = 500

    /// Resizes the key window to the app's original compact size (400×500 content).
    static func resetToCompactSize() {
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow else { return }
        window.setContentSize(NSSize(width: compactWidth, height: compactHeight))
    }
}
