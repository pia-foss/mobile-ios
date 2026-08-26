import UIKit

extension Notification.Name {
    public static let debugMenuRequested = Notification.Name("debugMenuRequested")
}

#if os(iOS) && !targetEnvironment(macCatalyst)
    extension UIWindow {
        open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                NotificationCenter
                    .default
                    .post(name: .debugMenuRequested, object: nil)
            }
        }
    }
#endif
