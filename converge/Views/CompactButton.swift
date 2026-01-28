//
//  CompactButton.swift
//  pomodoro
//

import SwiftUI

struct CompactButton: View {
    @StateObject private var windowObserver = WindowObserver()

    private var iconName: String {
        return windowObserver.isCompact ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left"
    }

    private var helpText: String {
        return windowObserver.isCompact ? "Maximize window" : "Restore compact window size"
    }

    var body: some View {
        // If we are in full screen, we hide the button entirely.
        if !windowObserver.isFullScreen {
            Button {
                if windowObserver.isCompact {
                   CompactWindowService.performZoom()
                } else {
                   CompactWindowService.resetToCompactSize()
                }
            } label: {
                Label("Toggle", systemImage: iconName)
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .contentShape(Circle())
                    .glassEffect(.regular.interactive(), in: Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .help(helpText)
            .animation(.easeInOut, value: iconName)
            .transition(.opacity)
        }
    }
}
