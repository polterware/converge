//
//  CompactWindowService.swift
//  pomodoro
//

import AppKit
import QuartzCore

enum CompactWindowService {
    static let compactWidth: CGFloat = 400
    static let compactHeight: CGFloat = 500

    private static let animationDuration: TimeInterval = 0.4

    /// Resizes the key window to the app's original compact size (400×500 content) with a smooth ease-in-out animation.
    static func resetToCompactSize() {
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow else { return }

        let contentRect = NSRect(x: 0, y: 0, width: compactWidth, height: compactHeight)
        let newFrameSize = NSWindow.frameRect(forContentRect: contentRect, styleMask: window.styleMask).size
        let frame = window.frame
        let newOrigin = NSPoint(x: frame.minX, y: frame.maxY - newFrameSize.height)
        let newFrame = NSRect(origin: newOrigin, size: newFrameSize)

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = Self.animationDuration
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(newFrame, display: true)
        }
    }
}
