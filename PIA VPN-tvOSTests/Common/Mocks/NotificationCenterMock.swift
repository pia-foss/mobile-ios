
import Foundation
import Combine
#if canImport(PIA_VPN_tvOS)
@testable import PIA_VPN_tvOS
#endif

class NotificationCenterMock: NotificationCenterType {
    var notificationPublisher: NotificationCenter.Publisher!
    func publisher(for name: Notification.Name, object: AnyObject?) -> NotificationCenter.Publisher {
        notificationPublisher
    }
    
    private(set) var addObserverCalled = false
    private(set) var addObserverCalledAttempt = 0
    private(set) var addObserverCalledWithNotificationName: NSNotification.Name? = nil
    
    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        addObserverCalled = true
        addObserverCalledAttempt += 1
        addObserverCalledWithNotificationName = aName
    }

    private(set) var removeObserverCalled = false
    private(set) var remoververCalledAttempt = 0
    func removeObserver(_ observer: Any) {
        removeObserverCalled = true
        remoververCalledAttempt += 1
    }
    
    private(set) var postNotificationCalledAttempt = 0
    private(set) var postNotificationCalledWithName: NSNotification.Name?
    func post(name aName: NSNotification.Name, object anObject: Any?) {
        postNotificationCalledAttempt += 1
        postNotificationCalledWithName = aName
    }
    
}
