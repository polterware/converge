//
//  ProgressCircleView.swift
//  pomodoro
//

import SwiftUI

struct ProgressCircleView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, color: Color, lineWidth: CGFloat = 8) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: animatedProgress)
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                animatedProgress = newValue
            }
        }
    }
}

struct ProgressCircleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ProgressCircleView(progress: 0.5, color: .red)
                .frame(width: 200, height: 200)
            
            ProgressCircleView(progress: 0.75, color: .blue)
                .frame(width: 150, height: 150)
        }
        .padding()
    }
}
