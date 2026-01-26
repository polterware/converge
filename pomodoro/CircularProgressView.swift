//
//  CircularProgressView.swift
//  pomodoro
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    
    init(progress: Double, lineWidth: CGFloat = 8, color: Color = .blue) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.color = color
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)
                .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 3)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CircularProgressView(progress: 0.3, color: .blue)
                .frame(width: 200, height: 200)
            
            CircularProgressView(progress: 0.7, color: .green)
                .frame(width: 150, height: 150)
            
            CircularProgressView(progress: 1.0, color: .red)
                .frame(width: 100, height: 100)
        }
        .padding()
    }
}
