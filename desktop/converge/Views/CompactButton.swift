//
//  CompactButton.swift
//  pomodoro
//

import SwiftUI

struct CompactButton: View {
    var body: some View {
        Button {
            CompactWindowService.resetToCompactSize()
        } label: {
            Label("Compact", systemImage: "arrow.down.right.and.arrow.up.left")
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .contentShape(Circle())
                .glassEffect(.regular.interactive(), in: Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .help("Restore compact window size")
    }
}
