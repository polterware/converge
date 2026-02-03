//
//  PomodoroView.swift
//  pomodoro
//

import SwiftUI

struct PomodoroView: View {
    let isActive: Bool
    @EnvironmentObject private var timer: PomodoroTimer
    @EnvironmentObject private var themeSettings: ThemeSettings
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .ignoresSafeArea()

                if isActive {
                    mainContent
                } else {
                    Color.clear
                }
            }
            .toolbarBackground(.hidden, for: .windowToolbar)
        }
    }

    private var mainContent: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: phaseIcon)
                    .font(.headline)
                    .foregroundColor(phaseColors.secondary)
                Text(phaseLabel)
                    .font(.headline)
                    .foregroundColor(phaseColors.secondary)
            }
            .animation(.easeInOut(duration: 0.3), value: timer.phase)

            ZStack {
                CircularProgressView(
                    progress: timer.progress,
                    lineWidth: 10,
                    color: phaseColors.primary
                )
                .frame(width: 220, height: 220)
                .animation(.linear(duration: 0.3), value: timer.progress)

                VStack(spacing: 4) {
                    Text(timer.formattedTime)
                        .font(.system(size: 48, weight: .medium, design: .monospaced))
                        .foregroundColor(phaseColors.primary)
                }
            }
            .transition(.scale.combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: timer.phase)

            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    Text("Completed: \(timer.completedPomodoros)")
                        .font(.subheadline)
                        .foregroundColor(phaseColors.secondary.opacity(0.7))
                }
                .transition(.opacity)

                if timer.phase != .break {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.subheadline)
                            .foregroundColor(phaseColors.secondary.opacity(0.7))
                        Text("Next Break: \(timer.nextBreakFormattedTime)")
                            .font(.subheadline)
                            .foregroundColor(phaseColors.secondary.opacity(0.7))
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: timer.phase)
                }
            }

            if timer.isWaitingForManualStart {
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            timer.startNextPhase()
                        }
                    } label: {
                        Label(
                            nextPhaseButtonLabel,
                            systemImage: nextPhaseButtonIcon
                        )
                        .labelStyle(.titleAndIcon)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(RoundedBorderedProminentButtonStyle(color: phaseColors.accent))

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            timer.reset()
                        }
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(RoundedBorderedButtonStyle(color: phaseColors.primary))
                }
                .animation(.easeInOut(duration: 0.3), value: timer.phase)
            } else {
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

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            timer.reset()
                        }
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(RoundedBorderedButtonStyle(color: phaseColors.primary))
                }
                .animation(.easeInOut(duration: 0.3), value: timer.phase)
            }
        }
        .padding(32)
    }
    
    private var phaseLabel: String {
        switch timer.phase {
        case .idle: return "Idle"
        case .work: return "Work"
        case .break: return "Break"
        }
    }
    
    private var phaseIcon: String {
        switch timer.phase {
        case .idle: return "timer"
        case .work: return "brain.head.profile"
        case .break: return "cup.and.saucer.fill"
        }
    }
    
    private var effectiveColorScheme: ColorScheme {
        themeSettings.currentColorScheme ?? systemColorScheme
    }
    
    private var phaseColors: PhaseColors {
        PhaseColors.color(for: timer.phase, colorScheme: effectiveColorScheme, isRunning: timer.isRunning)
    }
    
    private var nextPhaseButtonLabel: String {
        switch timer.phase {
        case .break:
            return "Start Break"
        case .work:
            return "Start Pomodoro"
        case .idle:
            return "Start"
        }
    }
    
    private var nextPhaseButtonIcon: String {
        switch timer.phase {
        case .break:
            return "cup.and.saucer.fill"
        case .work:
            return "brain.head.profile"
        case .idle:
            return "play.fill"
        }
    }
}

struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        let settings = PomodoroSettings()
        PomodoroView(isActive: true)
            .environmentObject(PomodoroTimer(settings: settings))
            .environmentObject(settings)
            .environmentObject(ThemeSettings())
    }
}
