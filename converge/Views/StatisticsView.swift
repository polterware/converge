//
//  StatisticsView.swift
//  pomodoro
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject private var store: StatisticsStore
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
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        countersSection
                        chartSection
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Statistics")
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

    private var countersSection: some View {
        HStack(spacing: 12) {
            StatCounter(label: "Today", value: store.pomodorosToday, phaseColors: phaseColors)
            StatCounter(label: "Week", value: store.pomodorosThisWeek, phaseColors: phaseColors)
            StatCounter(label: "Month", value: store.pomodorosThisMonth, phaseColors: phaseColors)
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.3), value: timer.phase)
        .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Productivity (last 14 days)")
                .font(.headline)
                .foregroundColor(phaseColors.primary)
                .animation(.easeInOut(duration: 0.3), value: timer.phase)
                .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
            Chart(store.chartData(days: 14)) { point in
                BarMark(
                    x: .value("Date", point.date),
                    y: .value("Pomodoros", point.count)
                )
                .foregroundStyle(phaseColors.accent)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                    AxisGridLine()
                        .foregroundStyle(phaseColors.secondary.opacity(0.3))
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        .foregroundStyle(phaseColors.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(phaseColors.secondary.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(phaseColors.secondary)
                }
            }
            .padding(.leading, 32)
            .animation(.easeInOut(duration: 0.3), value: timer.phase)
            .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
        }
    }
}

private struct StatCounter: View {
    let label: String
    let value: Int
    let phaseColors: PhaseColors

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(phaseColors.primary)
            Text(label)
                .font(.subheadline)
                .foregroundColor(phaseColors.secondary.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
}

#if DEBUG
#Preview {
    let settings = PomodoroSettings()
    StatisticsView()
        .environmentObject(StatisticsStore.shared)
        .environmentObject(PomodoroTimer(settings: settings))
        .environmentObject(settings)
        .environmentObject(ThemeSettings())
}
#endif
