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
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: timer.phase)
                    .animation(.easeInOut(duration: 0.5), value: timer.isRunning)
                
                Group {
                    if sessions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 48))
                                .foregroundColor(phaseColors.secondary.opacity(0.7))
                                .animation(.easeInOut(duration: 0.3), value: timer.phase)
                                .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
                            Text("No sessions yet")
                                .font(.headline)
                                .foregroundColor(phaseColors.primary)
                                .animation(.easeInOut(duration: 0.3), value: timer.phase)
                                .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
                            Text("Complete a pomodoro session to see it here")
                                .font(.subheadline)
                                .foregroundColor(phaseColors.secondary.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .animation(.easeInOut(duration: 0.3), value: timer.phase)
                                .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(sessions) { session in
                                HStack {
                                    Text(Self.dateFormatter.string(from: session.completedAt))
                                        .foregroundColor(phaseColors.primary)
                                    Spacer()
                                    Text(durationLabel(session.durationSeconds))
                                        .foregroundColor(phaseColors.secondary.opacity(0.7))
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .animation(.easeInOut(duration: 0.3), value: timer.phase)
                        .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
                    }
                }
            }
            .navigationTitle("History")
            .toolbarBackground(.hidden, for: .windowToolbar)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    SettingsToolbarButton {
                        WindowManager.shared.openSettingsWindow()
                    }
                }
            }
        }
    }
    
    private var effectiveColorScheme: ColorScheme {
        themeSettings.currentColorScheme ?? systemColorScheme
    }
    
    private var phaseColors: PhaseColors {
        PhaseColors.color(for: timer.phase, colorScheme: effectiveColorScheme, isRunning: timer.isRunning)
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
