//
//  StatisticsView.swift
//  pomodoro
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject private var store: StatisticsStore
    @EnvironmentObject private var themeSettings: ThemeSettings
    @Environment(\.colorScheme) private var systemColorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                PhaseColors.color(for: .idle, colorScheme: effectiveColorScheme).background
                    .ignoresSafeArea()
                
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

    private var countersSection: some View {
        HStack(spacing: 32) {
            StatCounter(label: "Today", value: store.pomodorosToday)
            StatCounter(label: "Week", value: store.pomodorosThisWeek)
            StatCounter(label: "Month", value: store.pomodorosThisMonth)
        }
        .frame(maxWidth: .infinity)
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Productivity (last 14 days)")
                .font(.headline)
            Chart(store.chartData(days: 14)) { point in
                BarMark(
                    x: .value("Date", point.date),
                    y: .value("Pomodoros", point.count)
                )
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                }
            }
        }
    }
}

private struct StatCounter: View {
    let label: String
    let value: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
        .environmentObject(settings)
        .environmentObject(ThemeSettings())
}
#endif
