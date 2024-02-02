
import Foundation

/// Expose Core Foundation APIs via protocols to the PIA app


protocol NotificationCenterType {
    func addObserver(
        _ observer: Any,
        selector aSelector: Selector,
        name aName: NSNotification.Name?,
        object anObject: Any?
    )
    
    func removeObserver(_ observer: Any)
    
    // Add methods here from NSNotificationCenter as needed
}

extension NotificationCenter: NotificationCenterType {}

extension Notification.Name {
    public static let DidInstallVPNProfile = Notification.Name("DidInstallVPNProfile")
}
