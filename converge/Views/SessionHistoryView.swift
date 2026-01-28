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

    @State private var selectedTimeRange: TimeRange = .thisWeek

    fileprivate static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    // Header date formatter (e.g., "Today", "Wednesday, Jan 29")
    private static let headerDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f
    }()

    private enum TimeRange: String, CaseIterable, Identifiable {
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case all = "All Time"

        var id: String { rawValue }
    }

    // MARK: - Data Models

    private struct DaySection {
        let date: Date
        let sessions: [PomodoroSession]
    }

    // MARK: - Data Logic

    private var filteredSessions: [PomodoroSession] {
        let now = Date()
        let calendar = Calendar.current

        return store.sessions.filter { session in
            switch selectedTimeRange {
            case .today:
                return calendar.isDateInToday(session.completedAt)
            case .thisWeek:
                return calendar.isDate(session.completedAt, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth:
                return calendar.isDate(session.completedAt, equalTo: now, toGranularity: .month)
            case .all:
                return true
            }
        }.sorted { $0.completedAt > $1.completedAt }
    }

    private func groupSessionsByDay(sessions: [PomodoroSession]) -> [DaySection] {
        let grouped = Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.completedAt)
        }

        return grouped.map { DaySection(date: $0.key, sessions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    private func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return Self.headerDateFormatter.string(from: date)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                mainContent
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

    // MARK: - Subviews

    private var backgroundView: some View {
        phaseColors.background
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: timer.phase)
            .animation(.easeInOut(duration: 0.5), value: timer.isRunning)
    }

    private var mainContent: some View {
        let sections = groupSessionsByDay(sessions: filteredSessions)

        return VStack(spacing: 0) {
            if sections.isEmpty {
                emptyStateView
            } else {
                sessionList(sections: sections)
            }
        }
    }

    private func sessionList(sections: [DaySection]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: []) {
                filterTimeline
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                ForEach(sections, id: \.date) { section in
                    Section {
                        ForEach(section.sessions) { session in
                            SessionRowView(session: session, phaseColors: phaseColors)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 4)
                        }
                    } header: {
                        HStack {
                            Text(sectionTitle(for: section.date))
                                .font(.headline)
                                .foregroundColor(phaseColors.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(phaseColors.background)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 40) // Add extra padding at the bottom
        }
        .scrollIndicators(.hidden)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(phaseColors.secondary.opacity(0.7))

            Text("No sessions found")
                .font(.headline)
                .foregroundColor(phaseColors.primary)

            Text("Try changing the filter or complete a pomodoro session.")
                .font(.subheadline)
                .foregroundColor(phaseColors.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
    }

    private var filterTimeline: some View {
        HStack {
            Spacer()
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.bottom)
    }


    // MARK: - Helpers

    private var effectiveColorScheme: ColorScheme {
        themeSettings.currentColorScheme ?? systemColorScheme
    }

    private var phaseColors: PhaseColors {
        PhaseColors.color(for: timer.phase, colorScheme: effectiveColorScheme, isRunning: timer.isRunning)
    }
}

// MARK: - Session Row View

struct SessionRowView: View {
    let session: PomodoroSession
    let phaseColors: PhaseColors

    private var startTime: String {
        let start = session.completedAt.addingTimeInterval(-Double(session.durationSeconds))
        return SessionHistoryView.timeFormatter.string(from: start)
    }

    private var endTime: String {
        return SessionHistoryView.timeFormatter.string(from: session.completedAt)
    }

    private var durationString: String {
        let minutes = session.durationSeconds / 60
        return "\(minutes) min"
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(startTime + " - " + endTime)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(phaseColors.primary)
            Spacer()
            Text(durationString)
                .font(.caption)
                .foregroundColor(phaseColors.secondary.opacity(0.8))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
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
        .frame(width: 400, height: 500)
}
#endif
