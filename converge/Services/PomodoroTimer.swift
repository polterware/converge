//
//  PomodoroTimer.swift
//  pomodoro
//

import Foundation
import Combine

enum PomodoroPhase: String {
    case idle
    case work
    case `break`
}

@MainActor
final class PomodoroTimer: ObservableObject {
    @Published var settings: PomodoroSettings
    
    @Published private(set) var remainingSeconds: Int
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var phase: PomodoroPhase = .idle
    @Published private(set) var completedPomodoros: Int = 0
    @Published private(set) var isWaitingForManualStart: Bool = false
    
    private var currentPhaseTotalSeconds: Int = 0

    private var timerCancellable: AnyCancellable?
    private var settingsCancellable: AnyCancellable?

    var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    var progress: Double {
        guard currentPhaseTotalSeconds > 0 else { return 0.0 }
        let elapsed = currentPhaseTotalSeconds - remainingSeconds
        return max(0.0, min(1.0, Double(elapsed) / Double(currentPhaseTotalSeconds)))
    }
    
    var nextBreakDurationSeconds: Int {
        let nextPomodoroCount = completedPomodoros + 1
        let isLongBreak = nextPomodoroCount % settings.pomodorosUntilLongBreak == 0
        return isLongBreak ? settings.longBreakDurationSeconds : settings.shortBreakDurationSeconds
    }
    
    var nextBreakType: String {
        let nextPomodoroCount = completedPomodoros + 1
        let isLongBreak = nextPomodoroCount % settings.pomodorosUntilLongBreak == 0
        return isLongBreak ? "Long Break" : "Short Break"
    }
    
    var nextBreakFormattedTime: String {
        let m = nextBreakDurationSeconds / 60
        let s = nextBreakDurationSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    init(settings: PomodoroSettings) {
        self.settings = settings
        self.remainingSeconds = settings.workDurationSeconds
        self.currentPhaseTotalSeconds = settings.workDurationSeconds
        
        // Observe changes in settings to update timer if needed
        settingsCancellable = settings.objectWillChange.sink { [weak self] _ in
            Task { @MainActor in
                self?.updateTimerFromSettings()
            }
        }
    }
    
    private func updateTimerFromSettings() {
        // Only update if timer is not running and in idle state
        guard !isRunning, phase == .idle else { return }
        remainingSeconds = settings.workDurationSeconds
        currentPhaseTotalSeconds = settings.workDurationSeconds
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true

        if phase == .idle {
            phase = .work
            remainingSeconds = settings.workDurationSeconds
            currentPhaseTotalSeconds = settings.workDurationSeconds
        }

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.tick()
                }
            }
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func reset() {
        pause()
        phase = .idle
        remainingSeconds = settings.workDurationSeconds
        currentPhaseTotalSeconds = settings.workDurationSeconds
        completedPomodoros = 0
        isWaitingForManualStart = false
    }

    private func tick() {
        guard isRunning else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            advanceToNextPhase()
        }
    }

    private func advanceToNextPhase() {
        switch phase {
        case .work:
            NotificationManager.shared.sendWorkCompleteNotification()
            StatisticsStore.shared.recordCompletedPomodoro(durationSeconds: settings.workDurationSeconds)
            completedPomodoros += 1
            
            // Determine if it's time for a long break
            let isLongBreak = completedPomodoros % settings.pomodorosUntilLongBreak == 0
            phase = .break
            
            if isLongBreak {
                remainingSeconds = settings.longBreakDurationSeconds
                currentPhaseTotalSeconds = settings.longBreakDurationSeconds
            } else {
                remainingSeconds = settings.shortBreakDurationSeconds
                currentPhaseTotalSeconds = settings.shortBreakDurationSeconds
            }
            
        case .break:
            NotificationManager.shared.sendBreakCompleteNotification()
            phase = .work
            remainingSeconds = settings.workDurationSeconds
            currentPhaseTotalSeconds = settings.workDurationSeconds
        case .idle:
            phase = .work
            remainingSeconds = settings.workDurationSeconds
            currentPhaseTotalSeconds = settings.workDurationSeconds
        }
        
        // Check if auto continue is enabled
        if settings.autoContinue {
            // Continue automatically - timer keeps running
        } else {
            // Manual mode - pause and wait for user confirmation
            pause()
            isWaitingForManualStart = true
        }
    }
    
    func startNextPhase() {
        guard isWaitingForManualStart else { return }
        isWaitingForManualStart = false
        start()
    }
}
