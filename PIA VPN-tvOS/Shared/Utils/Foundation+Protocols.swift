
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
    
    func post(name aName: NSNotification.Name, object anObject: Any?)
    
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

extension Date {
    static func makeISO8601Date(string: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        
        guard let date = dateFormatter.date(from: string) else { return nil }
        
        return date
    }
}

protocol URLSessionType {
    func data(from url: URL) async throws -> (Data, URLResponse)
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionType {}
