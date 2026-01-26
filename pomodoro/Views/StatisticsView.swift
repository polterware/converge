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
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                phaseColors.background
                    .ignoresSafeArea(edges: .all.subtracting(.top))
                    .animation(.easeInOut(duration: 0.5), value: timer.phase)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        countersSection
                        chartSection
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Statistics")
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
        .environmentObject(PomodoroTimer(settings: settings))
        .environmentObject(settings)
        .environmentObject(ThemeSettings())
}
#endif
