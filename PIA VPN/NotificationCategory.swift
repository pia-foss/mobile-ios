
import Foundation
import UserNotifications
import PIALibrary

public struct NotificationCategory {
    public static let nonCompliantWifi = "NONCOMPLIANTWIFI"
}


// MARK: Local Notifications

extension Macros {
    
    public static func showLocalNotification(_ id: String, type: String, body: String, info: [String: String] = [:], title: String? = nil, delay: Double = 0) {
        
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = type
        content.body = body
        if let title = title {
            content.title = title
        }
        content.userInfo = info
        
        // Fire in <delay> minutes (60 seconds times <delay>)
        var trigger : UNTimeIntervalNotificationTrigger? = nil
        if delay > 0 {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: (delay * 60), repeats: false)
        }
        
        // Create the request
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request)
        
    }
    
    public static func showLocalNotificationIfNotAlreadyPresent(_ id: String, type: String, body: String, info: [String: String] = [:], title: String? = nil, delay: Double = 1) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getDeliveredNotifications { notifications in
            // If the notification is not present in Notification Center, then show the notification
            if notifications.first(where:{ $0.request.identifier == id }) == nil {
                self.showLocalNotification(id, type: type, body: body, info: info, title: title, delay: delay)
            }
        }
    }
    
    public static func removeLocalNotification(_ id: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
    }
    
}
