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
    @State private var selectedDate: Date?
    @State private var mouseLocation: CGPoint?
    @State private var isHovering: Bool = false

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
        let chartData = store.chartData(days: 14)
        let selectedPoint = chartData.first { point in
            Calendar.current.isDate(point.date, inSameDayAs: selectedDate ?? Date.distantPast)
        }
        
        let monthFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter
        }()
        
        let currentMonth = chartData.last?.date ?? Date()
        
        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(monthFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(phaseColors.primary)
                    .animation(.easeInOut(duration: 0.3), value: timer.phase)
                    .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
                Text("Productivity (last 14 days)")
                    .font(.headline)
                    .foregroundColor(phaseColors.secondary.opacity(0.7))
                    .animation(.easeInOut(duration: 0.3), value: timer.phase)
                    .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
            }
            GeometryReader { geometry in
                ZStack {
                    let barWidth: CGFloat = {
                        guard !chartData.isEmpty else { return 20 }
                        let availableWidth = geometry.size.width
                        let spacePerBar = availableWidth / CGFloat(chartData.count)
                        let calculatedWidth = spacePerBar * 0.6
                        return max(8, min(calculatedWidth, 40))
                    }()
                    
                    Chart(chartData) { point in
                        BarMark(
                            x: .value("Date", point.date),
                            y: .value("Pomodoros", point.count),
                            width: .fixed(barWidth)
                        )
                        .foregroundStyle(phaseColors.accent)
                    }
                    .frame(height: 200)
                    .chartXSelection(value: $selectedDate)
                    .chartXAxis {
                        AxisMarks(values: chartData.map { $0.date }) { value in
                            AxisGridLine()
                                .foregroundStyle(phaseColors.secondary.opacity(0.3))
                            AxisValueLabel(format: .dateTime.day())
                                .foregroundStyle(phaseColors.secondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine()
                                .foregroundStyle(phaseColors.secondary.opacity(0.3))
                            AxisValueLabel()
                                .foregroundStyle(phaseColors.secondary)
                                .offset(x: -8)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: timer.phase)
                    .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
                    .onContinuousHover { phase in
                        switch phase {
                        case .active(let location):
                            mouseLocation = location
                            isHovering = true
                            
                            // Mapear posição X do mouse para a data correspondente
                            if !chartData.isEmpty {
                                let chartWidth = geometry.size.width
                                let relativeX = max(0, min(0.9999, location.x / chartWidth))
                                
                                // Dividir o espaço em segmentos iguais para cada barra
                                // Cada barra ocupa 1/n do espaço total
                                let segmentWidth = 1.0 / Double(chartData.count)
                                
                                // Calcular índice baseado em qual segmento o mouse está
                                var index = Int(relativeX / segmentWidth)
                                
                                // Garantir que o índice está no range válido (0 até count-1)
                                // Se o cálculo resultar em count ou maior, usar a última barra
                                if index >= chartData.count {
                                    index = chartData.count - 1
                                }
                                
                                selectedDate = chartData[index].date
                            }
                        case .ended:
                            isHovering = false
                            mouseLocation = nil
                            selectedDate = nil
                        }
                    }
                    
                    if let selectedPoint = selectedPoint, let mouseLocation = mouseLocation, isHovering {
                        let tooltipWidth: CGFloat = 120
                        let tooltipHeight: CGFloat = 80
                        let offsetX: CGFloat = 16
                        let offsetY: CGFloat = -16
                        
                        // Calcular posição absoluta do tooltip garantindo que não saia dos limites
                        let tooltipX: CGFloat = {
                            let preferredX = mouseLocation.x + offsetX
                            let rightEdge = preferredX + tooltipWidth / 2
                            
                            if rightEdge > geometry.size.width {
                                // Se sairia pela direita, colocar à esquerda do mouse
                                return mouseLocation.x - tooltipWidth / 2 - offsetX
                            } else if preferredX - tooltipWidth / 2 < 0 {
                                // Se sairia pela esquerda, ajustar
                                return tooltipWidth / 2 + offsetX
                            } else {
                                return preferredX
                            }
                        }()
                        
                        let tooltipY: CGFloat = {
                            let preferredY = mouseLocation.y + offsetY
                            let bottomEdge = preferredY + tooltipHeight / 2
                            
                            if bottomEdge > geometry.size.height {
                                // Se sairia por baixo, colocar acima do mouse
                                return mouseLocation.y - tooltipHeight / 2 - offsetY
                            } else if preferredY - tooltipHeight / 2 < 0 {
                                // Se sairia por cima, ajustar
                                return tooltipHeight / 2 + offsetY
                            } else {
                                return preferredY
                            }
                        }()
                        
                        TooltipView(
                            count: selectedPoint.count,
                            date: selectedPoint.date,
                            phaseColors: phaseColors
                        )
                        .position(x: tooltipX, y: tooltipY)
                        .transition(.opacity.combined(with: .scale))
                    }
                }
            }
            .frame(height: 200)
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

private struct TooltipView: View {
    let count: Int
    let date: Date
    let phaseColors: PhaseColors
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(count)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(phaseColors.primary)
            Text(count == 1 ? "Pomodoro" : "Pomodoros")
                .font(.caption)
                .foregroundColor(phaseColors.secondary.opacity(0.7))
            Text(dateFormatter.string(from: date))
                .font(.caption2)
                .foregroundColor(phaseColors.secondary.opacity(0.6))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
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
