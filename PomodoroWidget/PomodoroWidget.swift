//
//  PomodoroWidget.swift
//  PomodoroWidget
//
//  Created for Pomodoro Widget Extension
//

import WidgetKit
import SwiftUI

@main
struct PomodoroWidget: Widget {
    let kind: String = "PomodoroWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PomodoroWidgetTimelineProvider()) { entry in
            PomodoroWidgetView(entry: entry)
        }
        .configurationDisplayName("Pomodoro Timer")
        .description("View your Pomodoro timer status and progress.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
