
import Foundation
@testable import PIA_VPN_tvOS

class NotificationCenterMock: NotificationCenterType {
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
    
}
