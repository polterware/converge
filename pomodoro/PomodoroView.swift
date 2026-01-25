//
//  PomodoroView.swift
//  pomodoro
//

import SwiftUI

struct PomodoroView: View {
    @EnvironmentObject private var timer: PomodoroTimer

    var body: some View {
        VStack(spacing: 20) {
            Text(timer.formattedTime)
                .font(.system(size: 44, weight: .medium, design: .monospaced))

            Text(phaseLabel)
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button(timer.isRunning ? "Pause" : "Start") {
                    if timer.isRunning {
                        timer.pause()
                    } else {
                        timer.start()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") {
                    timer.reset()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
    }

    private var phaseLabel: String {
        switch timer.phase {
        case .idle: return "Idle"
        case .work: return "Work"
        case .break: return "Break"
        }
    }
}

struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroView()
            .environmentObject(PomodoroTimer())
    }
}
