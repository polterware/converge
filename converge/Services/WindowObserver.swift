//
//  WindowObserver.swift
//  converge
//
//  Created by Erick Barcelos on 27/01/26.
//

import SwiftUI
import Combine
import AppKit

class WindowObserver: ObservableObject {
    @Published var isFullScreen: Bool = false
    @Published var isCompact: Bool = true

    private var subscribers: [AnyCancellable] = []

    init() {
        setupObservers()
    }

    private func setupObservers() {
        NotificationCenter.default.publisher(for: NSWindow.didEnterFullScreenNotification)
            .sink { [weak self] _ in
                self?.isFullScreen = true
                self?.checkIfCompact()
            }
            .store(in: &subscribers)

        NotificationCenter.default.publisher(for: NSWindow.didExitFullScreenNotification)
            .sink { [weak self] _ in
                self?.isFullScreen = false
                self?.checkIfCompact()
            }
            .store(in: &subscribers)

        NotificationCenter.default.publisher(for: NSWindow.didResizeNotification)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.checkIfCompact()
            }
            .store(in: &subscribers)

        // Initial check
        DispatchQueue.main.async { [weak self] in
            self?.checkIfCompact()

            if let window = NSApp.keyWindow ?? NSApp.mainWindow {
                self?.isFullScreen = window.styleMask.contains(.fullScreen)
            }
        }
    }

    private func checkIfCompact() {
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow else { return }

        let width = window.frame.width

        // Use a small tolerance for floating point comparisons
        // Compact size is approx 400x500 (content size)
        // Window frame size includes title bar unless hidden/transparent

        // CompactWindowService defines content size 400x500.
        // We check if it's close to that.
        // Let's assume if width is <= 420 (allow some margin) it's compact.

        // Actually, let's just check if it's "small enough" or matches the specific compact dimensions.
        // CompactWindowService.compactWidth is 400.

        let isWidthCompact = abs(width - CompactWindowService.compactWidth) < 20 // 20px tolerance
        // Height might vary more if title bar is included or not, but let's check basic dimensions

        self.isCompact = isWidthCompact
    }
}
