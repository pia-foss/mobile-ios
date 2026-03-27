import UIKit

extension Notification.Name {
    public static let debugShakeDetected = Notification.Name("debugShakeDetected")
}

#if os(iOS)
    extension UIWindow {
        open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                NotificationCenter
                    .default
                    .post(name: .debugShakeDetected, object: nil)
            }
        }
    }
#endif
