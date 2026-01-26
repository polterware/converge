//
//  NotificationManager.swift
//  pomodoro
//

import Foundation
import UserNotifications
import AppKit

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    
    private let settings = NotificationSettings.shared
    private let notificationCenter = UNUserNotificationCenter.current()
    private lazy var notificationDelegate: NotificationDelegate = {
        let delegate = NotificationDelegate(notificationManager: self)
        notificationCenter.delegate = delegate
        return delegate
    }()
    
    private init() {
        // Configure delegate to always show notifications, even when app window is active
        // Access lazy property to trigger initialization
        _ = notificationDelegate
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
        content.title = "Pomodoro Complete!"
        content.body = "The 25 minutes of work are finished. Time for a break!"
        content.sound = getNotificationSound()
        
        sendNotification(content: content)
    }
    
    func sendBreakCompleteNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Break Complete!"
        content.body = "The break is over. Time to get back to work!"
        content.sound = getNotificationSound()
        
        sendNotification(content: content)
    }
    
    private func getNotificationSound() -> UNNotificationSound? {
        // Return nil to prevent system from playing default sound
        // We play the selected sound manually in the delegate
        return nil
    }
    
    func playSelectedSound() {
        guard settings.shouldPlaySound else {
            return
        }
        
        if let soundName = settings.soundType.systemSoundName {
            if let sound = NSSound(named: soundName) {
                sound.play()
            } else {
                // Fallback to beep if sound not found
                NSSound.beep()
            }
        } else {
            // Default sound - use beep
            NSSound.beep()
        }
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
    weak var notificationManager: NotificationManager?
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Play the selected system sound
        Task { @MainActor in
            notificationManager?.playSelectedSound()
        }
        
        // Always present notification as banner, even when app is in foreground
        // Note: We don't include .sound here since we're playing the sound manually
        completionHandler([.banner, .badge])
    }
}
