//
//  SessionHistoryView.swift
//  pomodoro
//

import SwiftUI

struct SessionHistoryView: View {
    @EnvironmentObject private var store: StatisticsStore
    @EnvironmentObject private var timer: PomodoroTimer
    @EnvironmentObject private var themeSettings: ThemeSettings
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showSettings = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        let sessions = store.recentSessions(limit: 50)

        NavigationStack {
            ZStack {
                phaseColors.background
                    .ignoresSafeArea(edges: .all.subtracting(.top))
                    .animation(.easeInOut(duration: 0.5), value: timer.phase)
                
                Group {
                    if sessions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("No sessions yet")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Complete a pomodoro session to see it here")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(sessions) { session in
                                HStack {
                                    Text(Self.dateFormatter.string(from: session.completedAt))
                                    Spacer()
                                    Text(durationLabel(session.durationSeconds))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        CompactWindowService.resetToCompactSize()
                    } label: {
                        Label("Compact", systemImage: "arrow.down.right.and.arrow.up.left")
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(.secondary)
                    }
                    .help("Restore compact window size")
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
    }
    
    private var effectiveColorScheme: ColorScheme {
        themeSettings.currentColorScheme ?? systemColorScheme
    }
    
    private var phaseColors: PhaseColors {
        PhaseColors.color(for: timer.phase, colorScheme: effectiveColorScheme)
    }

    private func durationLabel(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes) min"
    }
}

#if DEBUG
#Preview {
    let settings = PomodoroSettings()
    SessionHistoryView()
        .environmentObject(StatisticsStore.shared)
        .environmentObject(PomodoroTimer(settings: settings))
        .environmentObject(settings)
        .environmentObject(ThemeSettings())
}
#endif
