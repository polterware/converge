//
//  NotificationManager.swift
//  pomodoro
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    
    private let settings = NotificationSettings.shared
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    func requestAuthorization() async {
        do {
            try await notificationCenter.requestAuthorization(options: [.alert, .sound])
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }
    
    func sendWorkCompleteNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Completo!"
        content.body = "Os 25 minutos de trabalho terminaram. Hora de fazer uma pausa!"
        content.sound = getNotificationSound()
        
        sendNotification(content: content)
    }
    
    func sendBreakCompleteNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Pausa Terminada!"
        content.body = "A pausa terminou. Hora de voltar ao trabalho!"
        content.sound = getNotificationSound()
        
        sendNotification(content: content)
    }
    
    private func getNotificationSound() -> UNNotificationSound? {
        guard settings.shouldPlaySound else {
            return nil
        }
        
        // UserNotifications framework has limited system sound support
        // Use default sound for all cases as custom sounds require sound files
        return .default
    }
    
    private func sendNotification(content: UNMutableNotificationContent) {
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
}
