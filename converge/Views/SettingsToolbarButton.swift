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
            settingsLabel
        }
        .buttonStyle(PlainButtonStyle())
        .help("Settings")
    }

    @ViewBuilder
    private var settingsLabel: some View {
        Label("Settings", systemImage: "gearshape")
            .labelStyle(.iconOnly)
            .foregroundStyle(.secondary)
            .frame(width: 36, height: 36)
            .contentShape(Circle())
            .background(.ultraThinMaterial, in: Circle())
    }
}
