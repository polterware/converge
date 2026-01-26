//
//  DurationRow.swift
//  pomodoro
//

import SwiftUI

struct DurationRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String
    let iconName: String?
    
    init(label: String, value: Binding<Int>, range: ClosedRange<Int>, unit: String, iconName: String? = nil) {
        self.label = label
        self._value = value
        self.range = range
        self.unit = unit
        self.iconName = iconName
    }
    
    private var options: [Int] {
        generateRelevantOptions(for: range)
    }
    
    var body: some View {
        HStack {
            if let iconName = iconName {
                Label {
                    Text(label)
                } icon: {
                    Image(systemName: iconName)
                }
            } else {
                Text(label)
            }
            Spacer()
            
            Picker("", selection: $value) {
                ForEach(options, id: \.self) { option in
                    Text("\(option) \(unit)")
                        .tag(option)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 120)
        }
    }
    
    private func generateRelevantOptions(for range: ClosedRange<Int>) -> [Int] {
        let lower = range.lowerBound
        let upper = range.upperBound
        
        var options: [Int] = []
        
        // For time ranges (minutes), use common time intervals
        if upper <= 120 && lower >= 1 {
            // Common pomodoro time values
            let commonValues = [1, 2, 3, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120]
            options = commonValues.filter { range.contains($0) }
            
            // Add current value if not in common values
            if !options.contains(value) && range.contains(value) {
                options.append(value)
                options.sort()
            }
            
            // Fill gaps for small ranges
            if upper - lower <= 20 {
                options = Array(range).filter { $0 <= 20 || commonValues.contains($0) }
            }
        } else {
            // For count ranges (like pomodoros until long break)
            if upper <= 20 {
                options = Array(range)
            } else {
                // For larger ranges, use increments
                let step = max(1, (upper - lower) / 20)
                var current = lower
                while current <= upper {
                    options.append(current)
                    current += step
                }
                if !options.contains(upper) {
                    options.append(upper)
                }
            }
        }
        
        // Ensure current value is included
        if !options.contains(value) && range.contains(value) {
            options.append(value)
            options.sort()
        }
        
        return options
    }
}

struct DurationRow_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section("Timer Settings") {
                DurationRow(
                    label: "Work Duration",
                    value: .constant(25),
                    range: 1...120,
                    unit: "min"
                )
                DurationRow(
                    label: "Short Break Duration",
                    value: .constant(5),
                    range: 1...60,
                    unit: "min"
                )
                DurationRow(
                    label: "Pomodoros Until Long Break",
                    value: .constant(4),
                    range: 1...20,
                    unit: "count"
                )
            }
        }
        .formStyle(.grouped)
    }
}
