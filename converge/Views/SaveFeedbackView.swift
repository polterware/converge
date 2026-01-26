//
//  SaveFeedbackView.swift
//  pomodoro
//

import SwiftUI

struct SaveFeedbackView: View {
    @Binding var isVisible: Bool
    let message: String
    let iconName: String
    let iconColor: Color
    
    init(isVisible: Binding<Bool>, message: String = "Saved", iconName: String = "checkmark.circle.fill", iconColor: Color = .green) {
        self._isVisible = isVisible
        self.message = message
        self.iconName = iconName
        self.iconColor = iconColor
    }
    
    var body: some View {
        Group {
            if isVisible {
                HStack(spacing: 8) {
                    Image(systemName: iconName)
                        .foregroundStyle(iconColor)
                        .font(.title2)
                    
                    Text(message)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isVisible = false
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isVisible)
    }
}

struct SaveFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.2)
            
            SaveFeedbackView(isVisible: .constant(true))
        }
        .frame(width: 400, height: 300)
    }
}
