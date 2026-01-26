//
//  PomodoroView.swift
//  pomodoro
//

import SwiftUI

struct PomodoroView: View {
    @EnvironmentObject private var timer: PomodoroTimer
    @EnvironmentObject private var themeSettings: ThemeSettings
    @Environment(\.colorScheme) private var systemColorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                phaseColors.background
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: timer.phase)
                    .animation(.easeInOut(duration: 0.5), value: timer.isRunning)
                
                VStack(spacing: 20) {
                    ZStack {
                        CircularProgressView(
                            progress: timer.progress,
                            lineWidth: 10,
                            color: phaseColors.primary
                        )
                        .frame(width: 220, height: 220)
                        .animation(.easeInOut(duration: 0.3), value: timer.progress)
                        .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
                        
                        VStack(spacing: 4) {
                            Text(timer.formattedTime)
                                .font(.system(size: 48, weight: .medium, design: .monospaced))
                                .foregroundColor(phaseColors.primary)
                                .animation(.easeInOut(duration: 0.3), value: timer.phase)
                                .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                    
                    Text(phaseLabel)
                        .font(.headline)
                        .foregroundColor(phaseColors.secondary)
                        .animation(.easeInOut(duration: 0.3), value: timer.phase)
                        .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
                    
                    if timer.completedPomodoros > 0 {
                        Text("Completed: \(timer.completedPomodoros)")
                            .font(.subheadline)
                            .foregroundColor(phaseColors.secondary.opacity(0.7))
                            .transition(.opacity)
                    }

                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if timer.isRunning {
                                    timer.pause()
                                } else {
                                    timer.start()
                                }
                            }
                        } label: {
                            Label(
                                timer.isRunning ? "Pause" : "Start",
                                systemImage: timer.isRunning ? "pause.fill" : "play.fill"
                            )
                            .labelStyle(.titleAndIcon)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(RoundedBorderedProminentButtonStyle(color: phaseColors.accent))
                        .animation(.easeInOut(duration: 0.3), value: timer.phase)
                        .animation(.easeInOut(duration: 0.3), value: timer.isRunning)

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                timer.reset()
                            }
                        } label: {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                                .labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(RoundedBorderedButtonStyle(color: phaseColors.primary))
                        .animation(.easeInOut(duration: 0.3), value: timer.phase)
                        .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
                    }
                }
                .padding(32)
            }
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

    private var phaseLabel: String {
        switch timer.phase {
        case .idle: return "Idle"
        case .work: return "Work"
        case .break: return "Break"
        }
    }
    
    private var effectiveColorScheme: ColorScheme {
        themeSettings.currentColorScheme ?? systemColorScheme
    }
    
    private var phaseColors: PhaseColors {
        PhaseColors.color(for: timer.phase, colorScheme: effectiveColorScheme, isRunning: timer.isRunning)
    }
}

struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        let settings = PomodoroSettings()
        PomodoroView()
            .environmentObject(PomodoroTimer(settings: settings))
            .environmentObject(settings)
    }
}
