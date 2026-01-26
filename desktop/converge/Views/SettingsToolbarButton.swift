//
//  SettingsToolbarButton.swift
//  pomodoro
//

import SwiftUI

struct SettingsToolbarButton: View {
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Label("Settings", systemImage: "gearshape")
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .contentShape(Circle())
                .glassEffect(.regular.interactive(), in: Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .help("Settings")
    }
}
