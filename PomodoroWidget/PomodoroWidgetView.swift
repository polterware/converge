//
//  PomodoroWidgetView.swift
//  PomodoroWidget
//
//  Created for Pomodoro Widget Extension
//

import WidgetKit
import SwiftUI

struct PomodoroWidgetView: View {
    var entry: PomodoroWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    var entry: PomodoroWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: entry.phase.iconName)
                .font(.system(size: 24))
                .foregroundColor(phaseColor)
            
            Text(entry.formattedTime)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
            
            Text(entry.phase.displayName)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if entry.isRunning {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Running")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }
    
    private var phaseColor: Color {
        switch entry.phase {
        case .work:
            return entry.isRunning ? Color.red : Color.red.opacity(0.6)
        case .break:
            return entry.isRunning ? Color.blue : Color.blue.opacity(0.6)
        case .idle:
            return Color.gray
        }
    }
    
    private var backgroundColor: Color {
        switch entry.phase {
        case .work:
            return entry.isRunning 
                ? Color.red.opacity(0.1) 
                : Color.red.opacity(0.05)
        case .break:
            return entry.isRunning 
                ? Color.blue.opacity(0.1) 
                : Color.blue.opacity(0.05)
        case .idle:
            return Color.gray.opacity(0.05)
        }
    }
}

struct MediumWidgetView: View {
    var entry: PomodoroWidgetEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: entry.phase.iconName)
                        .font(.title2)
                        .foregroundColor(phaseColor)
                    
                    Text(entry.phase.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Text(entry.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                
                if entry.isRunning {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Running")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                CircularProgressView(
                    progress: entry.progress,
                    lineWidth: 8,
                    color: phaseColor
                )
                .frame(width: 80, height: 80)
                
                if entry.completedPomodoros > 0 {
                    Text("\(entry.completedPomodoros) completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }
    
    private var phaseColor: Color {
        switch entry.phase {
        case .work:
            return entry.isRunning ? Color.red : Color.red.opacity(0.6)
        case .break:
            return entry.isRunning ? Color.blue : Color.blue.opacity(0.6)
        case .idle:
            return Color.gray
        }
    }
    
    private var backgroundColor: Color {
        switch entry.phase {
        case .work:
            return entry.isRunning 
                ? Color.red.opacity(0.1) 
                : Color.red.opacity(0.05)
        case .break:
            return entry.isRunning 
                ? Color.blue.opacity(0.1) 
                : Color.blue.opacity(0.05)
        case .idle:
            return Color.gray.opacity(0.05)
        }
    }
}

struct LargeWidgetView: View {
    var entry: PomodoroWidgetEntry
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: entry.phase.iconName)
                    .font(.title)
                    .foregroundColor(phaseColor)
                
                Text(entry.phase.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if entry.isRunning {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Running")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(entry.formattedTime)
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
            
            CircularProgressView(
                progress: entry.progress,
                lineWidth: 12,
                color: phaseColor
            )
            .frame(width: 120, height: 120)
            
            if entry.completedPomodoros > 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(entry.completedPomodoros) Pomodoro\(entry.completedPomodoros == 1 ? "" : "s") completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }
    
    private var phaseColor: Color {
        switch entry.phase {
        case .work:
            return entry.isRunning ? Color.red : Color.red.opacity(0.6)
        case .break:
            return entry.isRunning ? Color.blue : Color.blue.opacity(0.6)
        case .idle:
            return Color.gray
        }
    }
    
    private var backgroundColor: Color {
        switch entry.phase {
        case .work:
            return entry.isRunning 
                ? Color.red.opacity(0.1) 
                : Color.red.opacity(0.05)
        case .break:
            return entry.isRunning 
                ? Color.blue.opacity(0.1) 
                : Color.blue.opacity(0.05)
        case .idle:
            return Color.gray.opacity(0.05)
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
    }
}

struct PomodoroWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PomodoroWidgetView(entry: PomodoroWidgetEntry(
                date: Date(),
                phase: .work,
                remainingSeconds: 15 * 60,
                isRunning: true,
                completedPomodoros: 2
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            PomodoroWidgetView(entry: PomodoroWidgetEntry(
                date: Date(),
                phase: .work,
                remainingSeconds: 15 * 60,
                isRunning: true,
                completedPomodoros: 2
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            PomodoroWidgetView(entry: PomodoroWidgetEntry(
                date: Date(),
                phase: .break,
                remainingSeconds: 3 * 60,
                isRunning: true,
                completedPomodoros: 3
            ))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
