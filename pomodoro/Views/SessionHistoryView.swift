//
//  SessionHistoryView.swift
//  pomodoro
//

import SwiftUI

struct SessionHistoryView: View {
    @EnvironmentObject private var store: StatisticsStore

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        let sessions = store.recentSessions(limit: 50)
        
        if sessions.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "clock.badge.questionmark")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("No sessions yet")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Complete a pomodoro session to see it here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
        } else {
            List {
                ForEach(sessions) { session in
                    HStack {
                        Text(Self.dateFormatter.string(from: session.completedAt))
                        Spacer()
                        Text(durationLabel(session.durationSeconds))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .background(.ultraThinMaterial)
        }
    }

    private func durationLabel(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes) min"
    }
}

#if DEBUG
#Preview {
    SessionHistoryView()
        .environmentObject(StatisticsStore.shared)
}
#endif
