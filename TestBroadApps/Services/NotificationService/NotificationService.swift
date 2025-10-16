//
//  NotificationService.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 12.10.2025.
//

import Foundation
import UserNotifications
import UIKit

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    func configure() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let open = UNNotificationAction(identifier: "OPEN_RESULT", title: "Open", options: [.foreground])
        let cat = UNNotificationCategory(identifier: "GENERATION_FINISHED", actions: [open], intentIdentifiers: [], options: [])
        center.setNotificationCategories([cat])
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, err in
            if let err = err { print("🔔 notif auth error:", err.localizedDescription) }
            print("🔔 notif permission:", granted)
        }
    }
    
    func scheduleGenerationFinished(id: String, body: String = "Your generated photo is ready.", attachmentURL: URL? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Image ready"
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "GENERATION_FINISHED"
        content.userInfo = ["generationId": id]
        
        if let fileURL = attachmentURL,
           let att = try? UNNotificationAttachment(identifier: "preview", url: fileURL, options: nil) {
            content.attachments = [att]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: "gen.\(id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { err in
            if let err = err { print("🔔 notif schedule error:", err.localizedDescription) }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let id = response.notification.request.content.userInfo["generationId"] as? String
        // Бросаем во внутреннее радио, чтобы Router открыл нужный экран
        if let id = id {
            NotificationCenter.default.post(name: .openGenerationFromNotification, object: nil, userInfo: ["generationId": id])
        }
        completionHandler()
    }
}

extension NotificationService {
    
    /// Проверяет, включены ли уведомления пользователем
    func getNotificationStatus() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized ||
               settings.authorizationStatus == .provisional
    }
    
    /// Запрашивает разрешение на уведомления
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            print("🔔 Permission granted:", granted)
            return granted
        } catch {
            print("❌ Notification permission error:", error.localizedDescription)
            return false
        }
    }
    
    /// «Отключить уведомления» — прямого API нет, можно только открыть настройки
    func openSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}
