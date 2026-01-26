//
//  WindowManager.swift
//  pomodoro
//

import SwiftUI
import AppKit

@MainActor
final class WindowManager {
    static let shared = WindowManager()
    
    private var openWindowAction: ((String) -> Void)?
    
    private init() {}
    
    func setOpenWindowAction(_ action: @escaping (String) -> Void) {
        openWindowAction = action
    }
    
    func openSettingsWindow() {
        NSApp.activate(ignoringOtherApps: true)
        
        let windowTitle = "Converge Settings"
        
        // Check if window already exists
        if let existingWindow = NSApp.windows.first(where: { window in
            window.isVisible && window.title == windowTitle
        }) {
            // Window exists, just bring it to front
            existingWindow.makeKeyAndOrderFront(nil)
            existingWindow.orderFrontRegardless()
        } else {
            // Window doesn't exist, use the openWindow action if available
            openWindowAction?("converge-settings")
        }
    }
}
