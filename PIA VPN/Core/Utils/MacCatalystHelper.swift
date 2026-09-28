import UIKit

#if targetEnvironment(macCatalyst)
    enum MacCatalystHelper {
        private static var keyWindowsObserver: NSObjectProtocol?

        /// Allow new `NSWindow`s to close even when there are modals presented.
        static func allowQuitWhileModal() {
            guard keyWindowsObserver == nil else { return }

            let setter = NSSelectorFromString("setPreventsApplicationTerminationWhenModal:")
            let key = "preventsApplicationTerminationWhenModal"

            keyWindowsObserver = NotificationCenter.default.addObserver(
                forName: Notification.Name("NSWindowDidBecomeKeyNotification"),
                object: nil,
                queue: .main
            ) { notification in
                guard let window = notification.object as? NSObject,
                    window.responds(to: setter)
                else { return }

                window.setValue(false, forKey: key)
            }
        }
    }
#endif
