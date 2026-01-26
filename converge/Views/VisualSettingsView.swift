//
//  VisualSettingsView.swift
//  pomodoro
//

import SwiftUI

struct VisualSettingsView: View {
    @EnvironmentObject private var themeSettings: ThemeSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section("Theme") {
                Picker("Appearance", selection: $themeSettings.selectedTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
                
                Text("Choose how the app should appear. Automatic follows your system settings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Visual Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct VisualSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VisualSettingsView()
                .environmentObject(ThemeSettings())
        }
    }
}
