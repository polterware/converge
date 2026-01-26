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
    private let notificationDelegate = NotificationDelegate()
    
    private init() {
        // Configure delegate to always show notifications, even when window is active
        notificationCenter.delegate = notificationDelegate
    }
    
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

// Delegate to force notifications to always be presented, even when app window is active
private class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Always present notification as banner, even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
