//
//  UpdateSettingsSection.swift
//  pomodoro
//
//  Settings section for app updates
//

import SwiftUI

struct UpdateSettingsSection: View {
    @StateObject private var updateManager = UpdateManager.shared
    @State private var isCheckingForUpdates = false
    
    var body: some View {
        Section("Updates") {
            HStack {
                Text("Current Version")
                Spacer()
                Text(updateManager.fullVersionString)
                    .foregroundStyle(.secondary)
            }
            
            if updateManager.canCheckForUpdates {
                Button {
                    isCheckingForUpdates = true
                    updateManager.checkForUpdates()
                    // Reset after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isCheckingForUpdates = false
                    }
                } label: {
                    HStack {
                        if isCheckingForUpdates {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Check for Updates")
                    }
                }
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                    Text("Automatic updates not configured")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
