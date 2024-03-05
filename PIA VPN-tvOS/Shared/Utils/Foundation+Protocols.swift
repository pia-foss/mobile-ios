
import Foundation
import CoreImage

/// Expose Core Foundation APIs via protocols to the PIA app


protocol NotificationCenterType {
    func addObserver(
        _ observer: Any,
        selector aSelector: Selector,
        name aName: NSNotification.Name?,
        object anObject: Any?
    )
    
    func removeObserver(_ observer: Any)
    
    func publisher(for name: Notification.Name, object: AnyObject?) -> NotificationCenter.Publisher
    
    // Add methods here from NSNotificationCenter as needed
}

extension NotificationCenter: NotificationCenterType {}

extension Notification.Name {
    public static let DidInstallVPNProfile = Notification.Name("DidInstallVPNProfile")
}

extension CustomStringConvertible {
    func asQRCode(scale: Double = 10) -> CIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        let stringRepresentation = String(describing: self)
        let data = stringRepresentation.data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        guard let ciimage = filter.outputImage else {
            return nil
        }
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledCIImage = ciimage.transformed(by: transform)
        
        return scaledCIImage
    }
}
