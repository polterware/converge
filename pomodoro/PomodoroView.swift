//
//  PomodoroView.swift
//  pomodoro
//

import SwiftUI

struct PomodoroView: View {
    @EnvironmentObject private var timer: PomodoroTimer
    @EnvironmentObject private var themeSettings: ThemeSettings
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                phaseColors.background
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: timer.phase)
                
                VStack(spacing: 20) {
                    ZStack {
                        CircularProgressView(
                            progress: timer.progress,
                            lineWidth: 10,
                            color: phaseColors.primary
                        )
                        .frame(width: 220, height: 220)
                        .animation(.easeInOut(duration: 0.3), value: timer.progress)
                        
                        VStack(spacing: 4) {
                            Text(timer.formattedTime)
                                .font(.system(size: 48, weight: .medium, design: .monospaced))
                                .foregroundColor(phaseColors.primary)
                                .animation(.easeInOut(duration: 0.3), value: timer.phase)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                    
                    Text(phaseLabel)
                        .font(.headline)
                        .foregroundColor(phaseColors.secondary)
                        .animation(.easeInOut(duration: 0.3), value: timer.phase)
                    
                    if timer.completedPomodoros > 0 {
                        Text("Completed: \(timer.completedPomodoros)")
                            .font(.subheadline)
                            .foregroundColor(phaseColors.secondary.opacity(0.7))
                            .transition(.opacity)
                    }

                    HStack(spacing: 12) {
                        Button(timer.isRunning ? "Pause" : "Start") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if timer.isRunning {
                                    timer.pause()
                                } else {
                                    timer.start()
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(phaseColors.accent)
                        .animation(.easeInOut(duration: 0.3), value: timer.phase)

                        Button("Reset") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                timer.reset()
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(phaseColors.primary)
                        .animation(.easeInOut(duration: 0.3), value: timer.phase)
                    }
                }
                .padding(32)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        CompactWindowService.resetToCompactSize()
                    } label: {
                        Image(systemName: "rectangle.compress.vertical")
                            .foregroundStyle(.secondary)
                    }
                    .help("Restore compact window size")
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
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
        PhaseColors.color(for: timer.phase, colorScheme: effectiveColorScheme)
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
